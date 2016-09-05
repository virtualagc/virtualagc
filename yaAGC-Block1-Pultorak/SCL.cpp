/****************************************************************************
 * SCL - SCALER subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: SCL.cpp
 *
 * NOTES: see header file.
 *
 *****************************************************************************
 */
#include "SCL.h"
#include "CTR.h"
#include "MON.h"
regSCL SCL::register_SCL;
regF17 SCL::register_F17;
regF13 SCL::register_F13;
regF10 SCL::register_F10;
enum oneShotType
{ // **inferred; not defined in orignal R393 AGC4 spec.
  WAIT_FOR_TRIGGER = 0, OUTPUT_PULSE = 1, // LSB (bit 1) is the output bit for the one-shot
  WAIT_FOR_RESET = 2
};
void
SCL::doexecWP_F17()
{
  int bit = SCL::register_SCL.readField(17, 17);
  switch (register_F17.read())
    {
  case WAIT_FOR_TRIGGER:
    if (bit == 1)
      register_F17.write(OUTPUT_PULSE);
    break;
  case OUTPUT_PULSE:
    register_F17.write(WAIT_FOR_RESET);
    break;
  case WAIT_FOR_RESET:
    if (bit == 0)
      register_F17.write(WAIT_FOR_TRIGGER);
    break;
  default:
    ;
    }
}
void
SCL::doexecWP_F13()
{
  int bit = SCL::register_SCL.readField(13, 13);
  switch (register_F13.read())
    {
  case WAIT_FOR_TRIGGER:
    if (bit == 1)
      register_F13.write(OUTPUT_PULSE);
    break;
  case OUTPUT_PULSE:
    register_F13.write(WAIT_FOR_RESET);
    break;
  case WAIT_FOR_RESET:
    if (bit == 0)
      register_F13.write(WAIT_FOR_TRIGGER);
    break;
  default:
    ;
    }
}
void
SCL::doexecWP_F10()
{
  // RSB:  As John wrote this, 'bit' would be 0 for
  // the first 512 SCL, 1 for the next 1024, 0, for the
  // next 1024, and so on.  I.e., it would clock at
  // a 1 ms rate, given a 1.024MHz clock for SCL.
  // However, this is fed to TIME1,3,4, and they are
  // supposed to increment every 10 ms.  Possibly
  // he did this to speed up in debugging, since
  // otherwise you have to wait quite a long time to
  // see the timers increment.  At any rate, it's
  // wrong, and we have to slow it down by a factor
  // of 10.
  //int bit = SCL::register_SCL.readField(10, 10);
  int bit = ((SCL::register_SCL.read() / 10) >> 9) & 1;
  switch (register_F10.read())
    {
  case WAIT_FOR_TRIGGER:
    if (bit == 1)
      register_F10.write(OUTPUT_PULSE);
    break;
  case OUTPUT_PULSE:
    register_F10.write(WAIT_FOR_RESET);
    CTR::pcUp[TIME1] = 1;
    CTR::pcUp[TIME3] = 1;
    CTR::pcUp[TIME4] = 1;
    break;
  case WAIT_FOR_RESET:
    if (bit == 0)
      register_F10.write(WAIT_FOR_TRIGGER);
    break;
  default:
    ;
    }
}
unsigned
SCL::F17x()
{
  return register_F17.readField(1, 1);
}
unsigned
SCL::F13x()
{
  return register_F13.readField(1, 1);
}
unsigned
SCL::F10x()
{
  return register_F10.readField(1, 1);
}
void
SCL::doexecWP_SCL()
{
  if (MON::SCL_ENAB) // if the scaler is enabled
    {
//write((read() + 1) % outmask());
      register_SCL.write((register_SCL.read() + 1));
    }
}

