/****************************************************************************
 * CLK - CLOCK subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: CLK.h
 *
 * VERSIONS:
 *
 * DESCRIPTION:
 * Clock for the Block 1 Apollo Guidance Computer prototype (AGC4).
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
#ifndef CLK_H
#define CLK_H
#include "reg.h"
// define pointer-to-function type
typedef void
(*EXECTYPE)();
class CLK
{
public:
  static void
  doexecR(int pulse);
  static void
  doexecR_ALU(int pulse);
  static void
  doexecR_ALU_OR(int pulse);
  static void
  doexecW(int pulse);
  static void
  clkAGC();
  static reg* registerList[];
};
#endif
