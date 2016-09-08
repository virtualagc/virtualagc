/****************************************************************************
 * CRG - ADDRESSABLE CENTRAL REGISTER subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: CRG.cpp
 *
 * NOTES: see header file.
 *
 *****************************************************************************
 */
#include "CRG.h"
#include "SEQ.h"
#include "BUS.h"
regQ CRG::register_Q; // return address
regZ CRG::register_Z; // program counter
regLP CRG::register_LP; // lower accumulator
regA CRG::register_A; // accumulator
// BUS LINE ASSIGNMENTS
// Specify the assignment of bus lines to the inputs of a register (for a 'write'
// operation into a register). Each 'conv_' array specifies the inputs into a
// single register. The index into the array corresponds to the bit position in
// the register, where the first parameter (index=0) is bit 16 of the register (msb)
// and the last parameter (index=15) is register bit 1 (lsb). The value of
// the parameter identifies the bus line assigned to that register bit. 'BX'
// means 'don't care'; i.e.: leave that register bit alone.
unsigned CRG::conv_WALP_LP[] =
  { BX, BX, B1, BX, BX, BX, BX, BX, BX, BX, BX, BX, BX, BX, BX, BX };
unsigned CRG::conv_WALP_A[] =
  { SG, SG, US, B14, B13, B12, B11, B10, B9, B8, B7, B6, B5, B4, B3, B2 };
unsigned CRG::conv_WLP[] =
  { B1, B1, D0, B14, B13, B12, B11, B10, B9, B8, B7, B6, B5, B4, B3, B2 };
void
CRG::execWP_GENRST()
{
  register_Q.write(0);
  register_Z.write(0);
  register_LP.write(0);
  register_A.write(0);
}
void
CRG::execRP_RQ()
{
  BUS::glbl_READ_BUS = register_Q.read();
}
void
CRG::execRP_RA1()
{
  BUS::glbl_READ_BUS = register_Q.read();
}
void
CRG::execWP_WQ()
{
  register_Q.write(BUS::glbl_WRITE_BUS);
}
void
CRG::execWP_WA1()
{
  register_Q.write(BUS::glbl_WRITE_BUS);
}
void
CRG::execRP_RZ()
{
  BUS::glbl_READ_BUS = register_Z.read();
}
void
CRG::execRP_RA2()
{
  BUS::glbl_READ_BUS = register_Z.read();
}
void
CRG::execWP_WZ()
{
  register_Z.write(BUS::glbl_WRITE_BUS);
}
void
CRG::execWP_WA2()
{
  register_Z.write(BUS::glbl_WRITE_BUS);
}
void
CRG::execRP_RLP()
{
  BUS::glbl_READ_BUS = register_LP.read();
}
void
CRG::execRP_RA3()
{
  BUS::glbl_READ_BUS = register_LP.read();
}
void
CRG::execWP_WALP()
{
  register_LP.writeShift(BUS::glbl_WRITE_BUS, CRG::conv_WALP_LP);
  register_A.writeShift(BUS::glbl_WRITE_BUS, CRG::conv_WALP_A);
}
void
CRG::execWP_WLP()
{
  register_LP.writeShift(BUS::glbl_WRITE_BUS, CRG::conv_WLP);
}
void
CRG::execWP_WA3()
{
  register_LP.writeShift(BUS::glbl_WRITE_BUS, CRG::conv_WLP);
}
void
CRG::execRP_RA()
{
  BUS::glbl_READ_BUS = register_A.read();
}
void
CRG::execRP_RA0()
{
  BUS::glbl_READ_BUS = register_A.read();
}
void
CRG::execWP_WA()
{
  register_A.write(BUS::glbl_WRITE_BUS);
}
void
CRG::execWP_WA0()
{
  register_A.write(BUS::glbl_WRITE_BUS);
}
