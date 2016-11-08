/****************************************************************************
 * DSP - DSKY DISPLAY subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: DSP.cpp
 *
 * NOTES: see header file.
 *
 *****************************************************************************
 */
#include "DSP.h"
#include <string.h>
#include <iostream>
#include <stdio.h>
bool dskyChanged = false; // true when DSKY display changes
// major mode display
char DSP::MD1 = 0;
char DSP::MD2 = 0;
// verb display
char DSP::VD1 = 0;
char DSP::VD2 = 0;
// noun display
char DSP::ND1 = 0;
char DSP::ND2 = 0;
// R1
char DSP::R1S = 0;
char DSP::R1D1 = 0;
char DSP::R1D2 = 0;
char DSP::R1D3 = 0;
char DSP::R1D4 = 0;
char DSP::R1D5 = 0;
// R2
char DSP::R2S = 0;
char DSP::R2D1 = 0;
char DSP::R2D2 = 0;
char DSP::R2D3 = 0;
char DSP::R2D4 = 0;
char DSP::R2D5 = 0;
// R3
char DSP::R3S = 0;
char DSP::R3D1 = 0;
char DSP::R3D2 = 0;
char DSP::R3D3 = 0;
char DSP::R3D4 = 0;
char DSP::R3D5 = 0;
// These flags control the sign; if both bits are 0 or 1, there is no sign.
// Otherwise, the sign is set by the selected bit.
unsigned DSP::R1SP = 0;
unsigned DSP::R1SM = 0;
unsigned DSP::R2SP = 0;
unsigned DSP::R2SM = 0;
unsigned DSP::R3SP = 0;
unsigned DSP::R3SM = 0;
// flag controls 1 Hz flash of verb and noun display
unsigned DSP::flash = 0; // 0=flash off, 1=flash on
void
DSP::clearOut0()
{
  MD1 = MD2 = ' '; // major mode display
  VD1 = VD2 = ' '; // verb display
  ND1 = ND2 = ' '; // noun display
  R1S = R1D1 = R1D2 = R1D3 = R1D4 = R1D5 = ' '; // R1
  R2S = R2D1 = R2D2 = R2D3 = R2D4 = R2D5 = ' '; // R2
  R3S = R3D1 = R3D2 = R3D3 = R3D4 = R3D5 = ' '; // R3
  R1SP = R1SM = 0;
  R2SP = R2SM = 0;
  R3SP = R3SM = 0;
}
char
DSP::signConv(unsigned p, unsigned m)
{
  if (p && !m)
    return '+';
  else if (m && !p)
    return '-';
  else
    return ' ';
}
char
DSP::outConv(unsigned in)
{
  switch (in)
    {
  case 000:
    return ' ';
  case 025:
    return '0';
  case 003:
    return '1';
  case 031:
    return '2';
  case 033:
    return '3';
  case 017:
    return '4';
  case 036:
    return '5';
  case 034:
    return '6';
  case 023:
    return '7';
  case 035:
    return '8';
  case 037:
    return '9';
    }
  return ' '; // error
}
void
DSP::decodeRelayWord(unsigned in)
{
  unsigned charSelect = (in & 074000) >> 11; // get bits 15-12
  unsigned b11 = (in & 02000) >> 10; // get bit 11
  unsigned bHigh = (in & 01740) >> 5; // get bits 10-6
  unsigned bLow = in & 037;
//******************************
#ifdef NOTDEF
  char buf[80];
  sprintf(buf, "bits15-12: %02o, Bit11: %01o, bits10-6: %02o, bits5-1: %02o",
      charSelect, b11, bHigh, bLow);
  cout << buf << endl;
#endif
  dskyChanged = true;
//******************************
  switch (charSelect)
    {
  case 013:
    MD1 = outConv(bHigh);
    MD2 = outConv(bLow);
    break;
  case 012:
    VD1 = outConv(bHigh);
    VD2 = outConv(bLow);
    flash = b11;
    break;
  case 011:
    ND1 = outConv(bHigh);
    ND2 = outConv(bLow);
    break;
  case 010:
    R1D1 = outConv(bLow);
    break;
// UPACT not implemented
  case 007:
    R1SP = b11;
    R1S = signConv(R1SP, R1SM);
    R1D2 = outConv(bHigh);
    R1D3 = outConv(bLow);
    break;
  case 006:
    R1SM = b11;
    R1S = signConv(R1SP, R1SM);
    R1D4 = outConv(bHigh);
    R1D5 = outConv(bLow);
    break;
  case 005:
    R2SP = b11;
    R2S = signConv(R2SP, R2SM);
    R2D1 = outConv(bHigh);
    R2D2 = outConv(bLow);
    break;
  case 004:
    R2SM = b11;
    R2S = signConv(R2SP, R2SM);
    R2D3 = outConv(bHigh);
    R2D4 = outConv(bLow);
    break;
  case 003:
    R2D5 = outConv(bHigh);
    R3D1 = outConv(bLow);
    break;
  case 002:
    R3SP = b11;
    R3S = signConv(R3SP, R3SM);
    R3D2 = outConv(bHigh);
    R3D3 = outConv(bLow);
    break;
  case 001:
    R3SM = b11;
    R3S = signConv(R3SP, R3SM);
    R3D4 = outConv(bHigh);
    R3D5 = outConv(bLow);
    break;
    }
}
