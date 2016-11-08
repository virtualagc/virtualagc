/****************************************************************************
 * CTR - INVOLUNTARY PRIORITY COUNTER subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 10/25/02
 * FILE: CTR.cpp
 *
 * NOTES: see header file.
 *
 *****************************************************************************
 */
#include "CTR.h"
#include "INT.h"
#include "BUS.h"
#include "SEQ.h"
regUpCELL CTR::register_UpCELL; // latches the selected priority counter cell (0-7 (decimal))
regDnCELL CTR::register_DnCELL; // latches the selected priority counter cell (0-7 (decimal))
unsigned CTR::pcUp[8];
unsigned CTR::pcDn[8];
// PRIORITY COUNTERS
// ****************************************************
// The interrupt priorities are stored in RPCELL as 1-5, but
// the priority counter priorities are stored as 0-7; this
// inconsistency should be fixed, probably. Also, the method
// of address determination for the priority counters needs work
void
CTR::resetAllpc()
{
  for (int i = 0; i < 8; i++)
    {
      pcUp[i] = 0;
      pcDn[i] = 0;
    }
}
// priority encoder; outputs 0-7; 0=highest priority (OVCTR), 1=TIME2, 2=TIME1, etc
static bool newPriority = true; // a simulator performance optimization; not in the hardware AGC
unsigned
getPriority()
{
  // simulator optimization; don't recompute priority if the priority inputs haven't changed
  static unsigned priority = 7; // default (lowest priority)
  if (!newPriority)
    return priority;
  priority = 7; // default (lowest priority)
  for (int i = 0; i < 8; i++)
    {
      if (CTR::register_UpCELL.readField(i + 1, i + 1)
          | CTR::register_DnCELL.readField(i + 1, i + 1))
        {
          priority = i;
          break;
        }
    }
  newPriority = false;
  return priority;
}
unsigned
CTR::getSubseq()
{
  unsigned pc = getPriority();
  unsigned upCell = CTR::register_UpCELL.readField(pc + 1, pc + 1);
  unsigned dnCell = CTR::register_DnCELL.readField(pc + 1, pc + 1);
  if (upCell == 1 && dnCell == 0)
    return PINCSEL;
  else if (upCell == 0 && dnCell == 1)
    return MINCSEL;
  else
    return NOPSEL;
}
void
CTR::execWP_GENRST()
{
  register_UpCELL.write(0);
  register_DnCELL.write(0);
  resetAllpc();
}
void
CTR::execWP_WPCTR()
{
  // transfer cell data into up and down synch registers
  for (int i = 0; i < 8; i++)
    {
      register_UpCELL.writeField(i + 1, i + 1, pcUp[i]);
      register_DnCELL.writeField(i + 1, i + 1, pcDn[i]);
    }
  newPriority = true; // a simulator performance optimization; not in hardware AGC
}
// Selected counter address is requested at TP1.
// Counter address is latched at TP12
void
CTR::execRP_RSCT()
{
  BUS::glbl_READ_BUS = 034 + getPriority();
}
void
CTR::execWP_WOVR()
{
  unsigned pc = getPriority();
  if (register_UpCELL.readField(pc + 1, pc + 1))
    {
      pcUp[pc] = 0;
    }
  if (register_DnCELL.readField(pc + 1, pc + 1))
    {
      pcDn[pc] = 0;
    }
  // generate various actions in response to counter overflows:
  switch (BUS::testOverflow(BUS::glbl_WRITE_BUS))
    {
  case POS_OVF: // positive overflow
    switch (getPriority())
      // get the counter
      {
    case TIME1:
      CTR::pcUp[TIME2] = 1;
      break; // overflow from TIME1 increments TIME2
    case TIME3:
      INT::rupt[T3RUPT] = 1;
      break; // overflow from TIME3 triggers T3RUPT
    case TIME4:
      INT::rupt[DSRUPT] = 1;
      break; // overflow from TIME4 triggers DSRUPT
      }
    break;
  case NEG_OVF:
    break; // no actions for negative counter overflow
    }
}
void
CTR::execWP_WOVC()
{
  switch (BUS::testOverflow(BUS::glbl_WRITE_BUS))
    {
  case POS_OVF:
    CTR::pcUp[OVCTR] = 1;
    break; // incr OVCTR (034)
  case NEG_OVF:
    CTR::pcDn[OVCTR] = 1;
    break; // decr OVCTR (034)
    }
}
// register_PCELL: Overflow from the selected counter appears
// on the bus when WOVR or WOVC is asserted;
// it could be used to trigger an interrupt
// or routed to increment another counter
