/****************************************************************************
 * MBF - MEMORY BUFFER REGISTER subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: MBF.cpp
 *
 * NOTES: see header file.
 *
 *****************************************************************************
 */
#include "MBF.h"
#include "SEQ.h"
#include "ADR.h"
#include "BUS.h"
#include "PAR.h"
#include "MEM.h"
// The actual bit 15 of register_G is not used.
regG MBF::register_G; // memory buffer register (except bit 15: parity)
unsigned MBF::conv_RG[] =
  { SG, SG, B14, B13, B12, B11, B10, B9, B8, B7, B6, B5, B4, B3, B2, B1 };
unsigned MBF::conv_SBWG[] =
  { SGM, BX, B14, B13, B12, B11, B10, B9, B8, B7, B6, B5, B4, B3, B2, B1 };
unsigned MBF::conv_WE[] =
  { BX, SG, B14, B13, B12, B11, B10, B9, B8, B7, B6, B5, B4, B3, B2, B1 };
unsigned MBF::conv_W20[] =
  { B1, BX, SG, B14, B13, B12, B11, B10, B9, B8, B7, B6, B5, B4, B3, B2 };
unsigned MBF::conv_W21[] =
  { SG, BX, SG, B14, B13, B12, B11, B10, B9, B8, B7, B6, B5, B4, B3, B2 };
unsigned MBF::conv_W22[] =
  { B14, BX, B13, B12, B11, B10, B9, B8, B7, B6, B5, B4, B3, B2, B1, SG };
unsigned MBF::conv_W23[] =
  { SG, BX, B13, B12, B11, B10, B9, B8, B7, B6, B5, B4, B3, B2, B1, SG };
void
MBF::execWP_GENRST()
{
  register_G.write(0);
}
void
MBF::execRP_RG()
{
  if (ADR::GTR_17())
    {
      BUS::glbl_READ_BUS = register_G.shiftData(0, register_G.read(),
          MBF::conv_RG);
    }
}
void
MBF::execRP_WE()
{
  // Write G into memory; shift the sign to bit 15; parity is written from the
  // PAR subsystem
  MEM::MEM_DATA_BUS = (register_G.shiftData(0, MBF::register_G.read(),
      MBF::conv_WE));
}
void
MBF::execWP_WGn()
{
  register_G.write(BUS::glbl_WRITE_BUS);
}
void
MBF::execWP_WGx()
{
  // This is only used in PINC, MINC, and SHINC. Does not clear G
  // register; writes (ORs) into G from RWBus and writes into parity
  // from 1-15 generator. The sequence calls CLG in a previous TP to
  // reset G to zero, so the OR operation can be safely eliminated
  // from my implementation of the design.
  register_G.write(BUS::glbl_WRITE_BUS);
}
void
MBF::execWP_W20()
{
  register_G.writeShift(BUS::glbl_WRITE_BUS, MBF::conv_W20);
}
void
MBF::execWP_W21()
{
  register_G.writeShift(BUS::glbl_WRITE_BUS, MBF::conv_W21);
}
void
MBF::execWP_W22()
{
  register_G.writeShift(BUS::glbl_WRITE_BUS, MBF::conv_W22);
}
void
MBF::execWP_W23()
{
  register_G.writeShift(BUS::glbl_WRITE_BUS, MBF::conv_W23);
}
void
MBF::execWP_SBWG()
{
  register_G.writeShift(MEM::MEM_DATA_BUS, MBF::conv_SBWG);
}
