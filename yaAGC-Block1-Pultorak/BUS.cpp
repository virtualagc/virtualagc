/****************************************************************************
 * BUS - READ/WRITE BUS subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: BUS.cpp
 *
 * NOTES: see header file.
 *
 *****************************************************************************
 */
#include "BUS.h"
unsigned BUS::glbl_READ_BUS = 0;
unsigned BUS::glbl_WRITE_BUS = 0;
ovfState
BUS::testOverflow(unsigned bus)
{
  if ((bus & 0100000) && !(bus & 0040000))
    return NEG_OVF; // negative overflow
  else if (!(bus & 0100000) && (bus & 0040000))
    return POS_OVF; // positive overflow
  else
    return NO_OVF;
}
