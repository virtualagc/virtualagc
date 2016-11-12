/****************************************************************************
 * INP - INPUT REGISTER subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: INP.cpp
 *
 * NOTES: see header file.
 *
 *****************************************************************************
 */
#include "INP.h"
#include "SEQ.h"
#include "KBD.h"
#include "MON.h"
#include "BUS.h"
regIn0 INP::register_IN0; // input register 0
regIn1 INP::register_IN1; // input register 1
regIn2 INP::register_IN2; // input register 2
regIn3 INP::register_IN3; // input register 3
void
INP::execRP_RA4()
{
  // Sample the state of the inputs at the moment the
  // read pulse is asserted. In the H/W implementation,
  // register 0 is a buffer, not a latch.
  register_IN0.writeField(5, 1, KBD::kbd);
  register_IN0.writeField(6, 6, 0); // actually should be keypressed strobe
  register_IN0.writeField(14, 14, MON::SA);
  register_IN0.clk();
  BUS::glbl_READ_BUS = register_IN0.read();
}
void
INP::execRP_RA5()
{
  BUS::glbl_READ_BUS = register_IN1.read();
}
void
INP::execRP_RA6()
{
  BUS::glbl_READ_BUS = register_IN2.read();
}
void
INP::execRP_RA7()
{
  BUS::glbl_READ_BUS = register_IN3.read();
}
