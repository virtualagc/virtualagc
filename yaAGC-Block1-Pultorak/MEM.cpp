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
#ifdef USE_NCURSES
#include <ncurses.h>
#else
#include <stdio.h>
#define printw printf
#define endwin()
#endif
regEMEM MEM::register_EMEM[02000]; // erasable memory
// The amount of memory logically addressable, as opposed to physically addressable,
// is allocated in order to make sure that bad AGC instructions don't segfault the
// simulator.
regFMEM MEM::register_FMEM[02000 * (LOGICALFBANK + 1 )]; // fixed memory (lowest 02000 words ignored)
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
  // Address is 15 bits. This function is used by the simulator for examining
  // memory; it is not part of the AGC design.
  if ((address & 076000) == 0)
    return MEM::register_EMEM[address].read();
  return MEM::register_FMEM[address].read();
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
  if ((address & 076000) == 0)
    {
      if (address >= 02000)
        {
          printw("Error: Erasable address=%0o\n", address);
          endwin();
          exit(0);
        }
      MEM::register_EMEM[address].write(data);
      MEM::register_EMEM[address].clk(); // execute immediately
    }
  else
    {
      if (address >= 02000 * (LOGICALFBANK+1))
        {
          printw("Error: Fixed address=%o\n", address);
          ;
          endwin();
          exit(0);
        }
      MEM::register_FMEM[address].write(data);
      MEM::register_FMEM[address].clk(); // execute immediately
    }
}
