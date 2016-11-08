/****************************************************************************
 * TPG - TIME PULSE GENERATOR subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: TPG.h
 *
 * VERSIONS:
 *
 * DESCRIPTION:
 * Time Pulse Generator and Start/Stop Logic for the Block 1 Apollo Guidance
 * Computer prototype (AGC4).
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
#ifndef TPG_H
#define TPG_H
#include "reg.h"
// Start/Stop Logic and Time Pulse Generator Subsystem
enum tpType
{
  STBY = 0, PWRON = 1, TP1 = 2, // TIME PULSE 1: start of memory cycle time (MCT)
  TP2 = 3,
  TP3 = 4,
  TP4 = 5,
  TP5 = 6,
  TP6 = 7, // EMEM is available in G register by TP6
  TP7 = 8, // FMEM is available in G register by TP7
  TP8 = 9,
  TP9 = 10,
  TP10 = 11, // G register written to memory beginning at TP10
  TP11 = 12, // TIME PULSE 11: end of memory cycle time (MCT)
  TP12 = 13, // select new subsequence/select new instruction
  SRLSE = 14, // step switch release
  WAIT = 15
};
class regSG : public reg
{
public:
  regSG() :
      reg(4, "%02o")
  {
  }
};
class TPG
{
public:
  static void
  doexecWP_TPG();
  static regSG register_SG;
  static char* tpTypestring[];
};
#endif
