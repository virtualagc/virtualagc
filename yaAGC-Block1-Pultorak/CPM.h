/****************************************************************************
 *  CPM - CONTROL PULSE MATRIX subsystem
 *
 *  AUTHOR:     John Pultorak
 *  DATE:       9/22/01
 *  FILE:       CPM.h
 *
 *  VERSIONS:
 * 
 *  DESCRIPTION:
 *    Control Pulse Matrix for the Block 1 Apollo Guidance Computer prototype (AGC4).
 *
 *  SOURCES:
 *    Mostly based on information from "Logical Description for the Apollo 
 *    Guidance Computer (AGC4)", Albert Hopkins, Ramon Alonso, and Hugh 
 *    Blair-Smith, R-393, MIT Instrumentation Laboratory, 1963.
 *
 *  NOTES: 
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
  instructionSubsequenceDecoder(int CTR_field, int SQ_field, int STB_field);

  static const char* subseqString[];

  static void
  controlPulseMatrix();

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
  get_CPM_A(int BR2_field, int BR1_field, int TPG_field, int STB_field,
      int SQ_field, int CTR_field, bool LOOP6_field);

};

#endif
