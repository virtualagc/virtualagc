/****************************************************************************
 * DSP - DSKY DISPLAY subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: DSP.h
 *
 * VERSIONS:
 *
 * DESCRIPTION:
 * DSKY Display for the Block 1 Apollo Guidance Computer prototype (AGC4).
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
#ifndef DSP_H
#define DSP_H
class DSP
{
public:
  // DSKY display
  // major mode display
  static char MD1;
  static char MD2;
  // verb display
  static char VD1;
  static char VD2;
  // noun display
  static char ND1;
  static char ND2;
  // R1
  static char R1S;
  static char R1D1;
  static char R1D2;
  static char R1D3;
  static char R1D4;
  static char R1D5;
  // R2
  static char R2S;
  static char R2D1;
  static char R2D2;
  static char R2D3;
  static char R2D4;
  static char R2D5;
  // R3
  static char R3S;
  static char R3D1;
  static char R3D2;
  static char R3D3;
  static char R3D4;
  static char R3D5;
  // These flags control the sign; if both bits are 0 or 1, there is no sign.
  // Otherwise, the sign is set by the selected bit.
  static unsigned R1SP;
  static unsigned R1SM;
  static unsigned R2SP;
  static unsigned R2SM;
  static unsigned R3SP;
  static unsigned R3SM;
  // verb/noun flash
  static unsigned flash;
  static void
  clearOut0();
  static char
  signConv(unsigned p, unsigned m);
  static char
  outConv(unsigned in);
  static void
  decodeRelayWord(unsigned in);
};
#endif
