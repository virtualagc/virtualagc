/****************************************************************************
 * CPM - CONTROL PULSE MATRIX subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: CPM.h
 *
 * VERSIONS:
 *
 * DESCRIPTION:
 * Control Pulse Matrix for the Block 1 Apollo Guidance Computer prototype (AGC4).
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
#ifndef CPM_H
#define CPM_H
#include "TPG.h"
#include "SEQ.h"
class CPM
{
public:
  static subseq
  instructionSubsequenceDecoder(int counter_subseq, int SQ_field,
      int STB_field);
  static char* subseqString[];
  static void
  controlPulseMatrix();
  static void
  readEPROM(char* fileName, int* eprom);
  static int EPROM1_8[0x3fff + 1];
  static int EPROM9_16[0x3fff + 1];
  static int EPROM17_24[0x3fff + 1];
  static int EPROM25_32[0x3fff + 1];
  static int EPROM33_40[0x3fff + 1];
  static int EPROM41_48[0x3fff + 1];
  static int EPROM49_56[0x3fff + 1];
private:
  // Clear the list of currently asserted control pulses.
  static void
  clearControlPulses();
  // Assert the set of control pulses by adding them to the list of currently
  // active control signals.
  static void
  assert(cpType* pulse);
  // Assert a control pulse by adding it to the list of currently asserted
  // control pulses.
  static void
  assert(cpType pulse);
  static void
  get_CPM_A(int CPM_A_address);
  static void
  getControlPulses_EPROM(int address);
  static void
  checkEPROM(int inval, int lowbit);
};
#endif
