/****************************************************************************
 * KBD - DSKY KEYBOARD subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: KBD.cpp
 *
 * NOTES: see header file.
 *
 *****************************************************************************
 */
#include "KBD.h"
#include "INT.h"
#include "MEM.h"
// DSKY keyboard
keyInType KBD::kbd = KEYIN_NONE; // latches the last key entry from the DSKY
void
KBD::keypress(keyInType c)
{
  // latch the keycode
  kbd = c;
  MEM::writeMemory(04, 040 | c);
  // generate KEYRUPT interrupt
  INT::rupt[KEYRUPT] = 1;
}
