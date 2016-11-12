/****************************************************************************
 * PAR - PARITY GENERATION AND TEST subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: PAR.cpp
 *
 * NOTES: see header file.
 *
 *****************************************************************************
 */
#include "PAR.h"
#include "SEQ.h"
#include "BUS.h"
#include "MBF.h"
#include "ADR.h"
#include "MEM.h"
regP PAR::register_P;
regP2 PAR::register_P2;
regG15 PAR::register_G15; // memory buffer register bit 15
regPALM PAR::register_PALM; // PARITY ALARM FF
unsigned PAR::conv_WP[] =
  { BX, SG, B14, B13, B12, B11, B10, B9, B8, B7, B6, B5, B4, B3, B2, B1 };
void
PAR::execRP_WE()
{
  // Write parity into memory.
  MEM::MEM_PARITY_BUS = PAR::register_G15.read();
}
// IMPLEMENTATION NOTE: It has been empirically determined that the following
// control signals are mutually exclusive (there is never more than one of these
// generated at any time):
// GP, WGX, RP2, SBWG, CLG
// NOTE: WP clears register_P before writing into it. Strictly speaking, WPx isn't
// supposed to clear the register (should OR into the register), but in the counter
// sequences where WPx is used, register_P is always cleared in the previous TP by
// asserting WP with default zeroes on the write bus.
void
PAR::execWP_WP()
{
  // set all bits except parity bit
  register_P.writeShift(BUS::glbl_WRITE_BUS, PAR::conv_WP);
  // now set parity bit; in the actual AGC, this is
  // a single operation.
  if (SEQ::isAsserted(RG))
    register_P.writeField(16, 16, register_G15.read());
  else
    register_P.writeField(16, 16, 0); // clear parity bit
}
void
PAR::execWP_WPx()
{
  // set all bits except parity bit
  register_P.writeShift(BUS::glbl_WRITE_BUS, PAR::conv_WP);
  // now set parity bit; in the actual AGC, this is
  // a single operation.
  if (SEQ::isAsserted(RG))
    register_P.writeField(16, 16, register_G15.read());
  else
    register_P.writeField(16, 16, 0); // clear parity bit
}
void
PAR::execWP_WP2()
{
  register_P2.write(gen1_15Parity(register_P.read()));
}
void
PAR::execWP_RP2()
{
  register_G15.write(register_P2.read());
}
void
PAR::execWP_GP()
{
  register_G15.write(gen1_15Parity(register_P.read()));
}
void
PAR::execWP_SBWG()
{
  register_G15.write(MEM::MEM_PARITY_BUS); // load memory bit 16 (parity) into G15
}
void
PAR::execWP_WGx()
{
  // This is only used in PINC, MINC, and SHINC. Does not clear G
  // register; writes (ORs) into G from RWBus and writes into parity
  // from 1-15 generator. All done in one operation, although I show
  // it in two steps here. The sequence calls CLG in a previous TP.
  register_G15.write(PAR::gen1_15Parity(register_P.read()));
}
void
PAR::execWP_CLG()
{
  register_G15.write(0);
}
void
PAR::execWP_GENRST()
{
  register_PALM.write(0);
}
void
PAR::execWP_TP()
{
  if (ADR::GTR_27() && genP_15Parity(register_P.read()))
    register_PALM.write(genP_15Parity(register_P.read()));
}
void
PAR::CLR_PALM()
{
  // asynchronous clear for PARITY ALARM (from MON)
  register_PALM.clear();
}
unsigned
PAR::gen1_15Parity(unsigned r)
{
  //check the lower 15 bits of 'r' and return the odd parity;
  //bit 16 is ignored.
  unsigned evenParity = (1 & (r >> 0)) ^ (1 & (r >> 1)) ^ (1 & (r >> 2))
      ^ (1 & (r >> 3)) ^ (1 & (r >> 4)) ^ (1 & (r >> 5)) ^ (1 & (r >> 6))
      ^ (1 & (r >> 7)) ^ (1 & (r >> 8)) ^ (1 & (r >> 9)) ^ (1 & (r >> 10))
      ^ (1 & (r >> 11)) ^ (1 & (r >> 12)) ^ (1 & (r >> 13)) ^ (1 & (r >> 14));
  return ~evenParity & 1; // odd parity
}
unsigned
PAR::genP_15Parity(unsigned r)
{
  //check all 16 bits of 'r' and return the odd parity
  unsigned evenParity = (1 & (r >> 0)) ^ (1 & (r >> 1)) ^ (1 & (r >> 2))
      ^ (1 & (r >> 3)) ^ (1 & (r >> 4)) ^ (1 & (r >> 5)) ^ (1 & (r >> 6))
      ^ (1 & (r >> 7)) ^ (1 & (r >> 8)) ^ (1 & (r >> 9)) ^ (1 & (r >> 10))
      ^ (1 & (r >> 11)) ^ (1 & (r >> 12)) ^ (1 & (r >> 13)) ^ (1 & (r >> 14))
      ^ (1 & (r >> 15));
  return ~evenParity & 1; // odd parity
}
