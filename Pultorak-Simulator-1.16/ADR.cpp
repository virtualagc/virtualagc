/****************************************************************************
 * ADR - MEMORY ADDRESS subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: ADR.cpp
 *
 * NOTES: see header file.
 *
 *****************************************************************************
 */
#include "reg.h"
#include "ADR.h"
#include "SEQ.h"
#include "BUS.h"
regS ADR::register_S; // address register
regBNK ADR::register_BNK; // bank register
// transfer bits 14-11 from the bus into the 4-bit bank register
unsigned ADR::conv_WBK[] =
  { BX, BX, BX, BX, BX, BX, BX, BX, BX, BX, BX, BX, B14, B13, B12, B11 };
void
ADR::execWP_WS()
{
  register_S.write(BUS::glbl_WRITE_BUS);
}
void
ADR::execRP_RBK()
{
  BUS::glbl_READ_BUS = register_BNK.read() << 10;
}
void
ADR::execWP_WBK()
{
  register_BNK.writeShift(BUS::glbl_WRITE_BUS, ADR::conv_WBK);
}
bool
ADR::GTR_27()
{
  return (register_S.read() > 027);
}
bool
ADR::GTR_17()
{
  // check: address is not a central register
  return (register_S.read() > 017);
}
bool
ADR::EQU_25()
{
  return (register_S.read() == 025);
}
bool
ADR::EQU_17()
{
// check: instruction is INHINT (INDEX 017)
  return (register_S.read() == 017);
}
bool
ADR::EQU_16()
{
  // check: instruction is RELINT (INDEX 016))
  return (register_S.read() == 016);
}
bool
ADR::GTR_1777()
{
  // check: address is fixed memory
  return (register_S.read() > 01777);
}
unsigned
ADR::bankDecoder()
{
  // Memory is organized into 13 banks of 1K words each. The banks are numbered
  // 0-12. Bank 0 is erasable memory; banks 1-12 are fixed (rope) memory. The 10
  // lower bits in the S register address memory inside a bank. The 2 upper bits
  // in the S register select the bank. If the 2 upper bits are both 1, the 4-bit
  // bank register is used to select the bank.
  // 12 11 Bank
  // 0 0 0 erasable memory
  // 0 1 1 fixed-fixed 1 memory
  // 1 0 2 fixed-fixed 2 memory
  // 1 1 3-12 fixed-switchable memory (bank register selects bank)
  unsigned bank = ADR::register_S.readField(12, 11);
  if (bank == 3)
    {
      // fixed-switchable
      if (register_BNK.read() <= 03) // defaults to 6000 - 7777
        return 03;
      else
        return register_BNK.read(); // 10000 - 31777
    }
  else
    return bank; // erasable or fixed-fixed
}
unsigned
ADR::getEffectiveAddress()
{
  // Return the 14-bit address selected by lower 10 bits of the S register (1K)
  // and the bank decoder (which selects the 1K bank)
  unsigned lowAddress = ADR::register_S.readField(10, 1);
  if (ADR::bankDecoder() == 0)
    return lowAddress;
  unsigned highAddress = ADR::bankDecoder() << 10;
  return highAddress | lowAddress;
}
