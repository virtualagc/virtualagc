/****************************************************************************
 * ALU - ARITHMETIC UNIT subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: ALU.cpp
 *
 * NOTES: see header file.
 *
 *****************************************************************************
 */
#include "ALU.h"
#include "SEQ.h"
#include "BUS.h"
regB ALU::register_B; // next instruction
regCI ALU::register_CI; // ALU carry-in flip flop
regX ALU::register_X; // ALU X register
regY ALU::register_Y; // ALU Y register
regU ALU::register_U; // ALU sum
unsigned ALU::glbl_BUS = 0;
//************************************************************
void
ALU::execRP_ALU_RB()
{
  BUS::glbl_READ_BUS = register_B.read();
}
// Performs an inclusive OR or register U and register C;
// in the MASK instruction, the RC and RU control pulses
// are activated simultaneously. This causes both to be
// gated onto the AGC bus which performs the logical OR.
void
ALU::execRP_ALU_RC()
{
  ALU::glbl_BUS |= register_B.outmask() & (~register_B.read());
  BUS::glbl_READ_BUS = ALU::glbl_BUS;
}
// Performs an inclusive OR or register U and register C;
// in the MASK instruction, the RC and RU control pulses
// are activated simultaneously. This causes both to be
// gated onto the AGC bus which performs the logical OR.
void
ALU::execRP_ALU_RU()
{
  ALU::glbl_BUS |= register_U.read();
  BUS::glbl_READ_BUS = ALU::glbl_BUS;
}
//************************************************************
//************************************************************
// This is the interface between the read and write busses
void
ALU::execRP_ALU_OR_RB14()
{
  BUS::glbl_WRITE_BUS |= 0020000 | BUS::glbl_READ_BUS;
}
void
ALU::execRP_ALU_OR_R1()
{
  BUS::glbl_WRITE_BUS |= 0000001 | BUS::glbl_READ_BUS;
}
void
ALU::execRP_ALU_OR_R1C()
{
  BUS::glbl_WRITE_BUS |= 0177776 | BUS::glbl_READ_BUS;
}
void
ALU::execRP_ALU_OR_R2()
{
  BUS::glbl_WRITE_BUS |= 0000002 | BUS::glbl_READ_BUS;
}
void
ALU::execRP_ALU_OR_RSB()
{
  BUS::glbl_WRITE_BUS |= 0100000 | BUS::glbl_READ_BUS;
}
void
ALU::execRP_ALU_OR_R22()
{
  BUS::glbl_WRITE_BUS |= 0000022 | BUS::glbl_READ_BUS;
}
void
ALU::execRP_ALU_OR_R24()
{
  BUS::glbl_WRITE_BUS |= 0000024 | BUS::glbl_READ_BUS;
}
void
ALU::execRP_ALU_OR_R2000()
{
  BUS::glbl_WRITE_BUS |= 0002000 | BUS::glbl_READ_BUS; // TC GOPROG instruction
}
//************************************************************
void
ALU::execWP_GENRST()
{
}
void
ALU::execWP_CI()
{
  register_CI.writeField(1, 1, 1);
}
void
ALU::execWP_WX()
{
  register_X.write(BUS::glbl_WRITE_BUS);
}
void
ALU::execWP_WB()
{
  register_B.write(BUS::glbl_WRITE_BUS);
}
void
ALU::execWP_WYx()
{
  register_Y.write(BUS::glbl_WRITE_BUS);
}
void
ALU::execWP_WY()
{
  if (!SEQ::isAsserted(CI))
    register_CI.writeField(1, 1, 0);
  register_X.write(0);
  register_Y.write(BUS::glbl_WRITE_BUS);
}
unsigned
regU::read()
{
  unsigned carry = (outmask() + 1)
      & (ALU::register_X.read() + ALU::register_Y.read()); // end-around carry
  if (carry || ALU::register_CI.read())
    carry = 1;
  else
    carry = 0;
  return outmask() & (ALU::register_X.read() + ALU::register_Y.read() + carry);
}
