/****************************************************************************
 * KBD - DSKY KEYBOARD subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: KBD.h
 *
 * VERSIONS:
 *
 * DESCRIPTION:
 * DSKY Keyboard for the Block 1 Apollo Guidance Computer prototype (AGC4).
 *
 * SOURCES:
 * Mostly based on information from "Logical Description for the Apollo
 * Guidance Computer (AGC4)", Albert Hopkins, Ramon Alonso, and Hugh
 * Blair-Smith, R-393, MIT Instrumentation Laboratory, 1963.
 *
 * NOTES:
 *
 *****************************************************************************
 */
#ifndef KBD_H
#define KBD_H
enum keyInType
{
  // DSKY keyboard input codes: Taken from E-1574, Appendix 1
  // These codes enter the computer through bits 1-5 of IN0.
  // The MSB is in bit 5; LSB in bit 1. Key entry generates KEYRUPT.
  KEYIN_NONE = 0, // no key depressed**
  KEYIN_0 = 020,
  KEYIN_1 = 001,
  KEYIN_2 = 002,
  KEYIN_3 = 003,
  KEYIN_4 = 004,
  KEYIN_5 = 005,
  KEYIN_6 = 006,
  KEYIN_7 = 007,
  KEYIN_8 = 010,
  KEYIN_9 = 011,
  KEYIN_VERB = 021,
  KEYIN_ERROR_RESET = 022,
  KEYIN_KEY_RELEASE = 031,
  KEYIN_PLUS = 032,
  KEYIN_MINUS = 033,
  KEYIN_ENTER = 034,
  KEYIN_CLEAR = 036,
  KEYIN_NOUN = 037,
};
class KBD
{
public:
  static keyInType kbd; // latches the last key entry from the DSKY
  static void
  keypress(keyInType c);
};
#endif
