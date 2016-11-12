/****************************************************************************
 * MEM - ERASEABLE/FIXED MEMORY subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/26/02
 * FILE: MEM.cpp
 *
 * NOTES: see header file.
 *
 *****************************************************************************
 */
#include "MEM.h"
#include "ADR.h"
#include "stdlib.h"
regEMEM MEM::register_EMEM[1024]; // erasable memory
regFMEM MEM::register_FMEM[1024 * (NUMFBANK + 1)]; // fixed memory (lowest 1024 words ignored)
unsigned MEM::MEM_DATA_BUS = 0; // data lines: memory bits 15-1
unsigned MEM::MEM_PARITY_BUS = 0; // parity line: memory bit 16
void
MEM::execWP_WE()
{
  // Write into memory; parity bit in bit 16
  writeMemory((MEM_PARITY_BUS << 15) | MEM_DATA_BUS);
}
void
MEM::execRP_SBWG()
{
  MEM_DATA_BUS = readMemory() & 0077777; // everything except parity
  MEM_PARITY_BUS = (readMemory() & 0100000) >> 15; // parity bit only
}
unsigned
MEM::readMemory()
{
  // Return memory value addressed by lower 10 bits of the S register (1K) and the
  // bank decoder (which selects the 1K bank)
  unsigned lowAddress = ADR::register_S.readField(10, 1);
  if (ADR::bankDecoder() == 0)
    return MEM::register_EMEM[lowAddress].read();
  unsigned highAddress = ADR::bankDecoder() << 10;
  return MEM::register_FMEM[highAddress | lowAddress].read();
}
void
MEM::writeMemory(unsigned data)
{
  // Write into erasable memory addressed by lower 10 bits of the S register (1K)
  // and the bank decoder (which selects the 1K bank)
  unsigned lowAddress = ADR::register_S.readField(10, 1);
  if (ADR::bankDecoder() == 0)
    {
      MEM::register_EMEM[lowAddress].write(data);
      MEM::register_EMEM[lowAddress].clk(); // not a synchronous FF, so execute immediately *************
}
}
unsigned
MEM::readMemory(unsigned address)
{
// Address is 14 bits. This function is used by the simulator for examining
// memory; it is not part of the AGC design.
unsigned lowAddress = address & 01777;
unsigned bank = (address & 036000) >> 10;
if (bank == 0)
return MEM::register_EMEM[lowAddress].read();
unsigned highAddress = bank << 10;
return MEM::register_FMEM[highAddress | lowAddress].read();
}
void
MEM::writeMemory(unsigned address, unsigned data)
{
// Address is 14 bits. This function is used by the simulator for depositing into
// memory; it is not part of the AGC design. This function is also used to
// initialize fixed memory.
//************************************************************
// This function could also write the parity into memory
//************************************************************
unsigned lowAddress = address & 01777;
unsigned bank = (address & 036000) >> 10;
if (bank == 0)
{
  if (lowAddress > 1024)
    {
      cout << "Error: Eraseable address=" << lowAddress << endl;
      exit(0);
    }
  MEM::register_EMEM[lowAddress].write(data);
  MEM::register_EMEM[lowAddress].clk(); // execute immediately
}
else
{
  unsigned highAddress = bank << 10;
  if ((highAddress | lowAddress) >= 1024 * (NUMFBANK + 1))
    {
      cout << "Error: Fixed address=" << (highAddress | lowAddress) << endl;
      exit(0);
    }
  MEM::register_FMEM[highAddress | lowAddress].write(data);
  MEM::register_FMEM[highAddress | lowAddress].clk(); // execute immediately
}
}
