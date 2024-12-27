/*
 * Copyright 2016,2017 Ronald S. Burkey <info@sandroid.org>
 *
 * This file is part of yaAGC.
 *
 * yaAGC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * yaAGC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with yaAGC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * In addition, as a special exception, Ronald S. Burkey gives permission to
 * link the code of this program with the Orbiter SDK library (or with
 * modified versions of the Orbiter SDK library that use the same license as
 * the Orbiter SDK library), and distribute linked combinations including
 * the two. You must obey the GNU General Public License in all respects for
 * all of the code used other than the Orbiter SDK library. If you modify
 * this file, you may extend this exception to your version of the file,
 * but you are not obligated to do so. If you do not wish to do so, delete
 * this exception statement from your version.
 *
 * Filename:    yaDSKYb1.cpp
 * Purpose:     Common functionality for the different versions of the  Block
 *              1 DSKY simulation programs, yaDSKYb1-main and yaDSKYb1-nav.
 * Compiler:    GNU gcc.
 * Contact:     Ron Burkey <info@sandroid.org>
 * Reference:   http://www.ibiblio.org/apollo/index.html
 * Mods:        2016-09-04 RSB  Began.
 *              2017-03-24 RSB  From the written descriptions of behavior,
 *                              I originally thought that for the Block 1 DSKY,
 *                              flashing VERB/NOUN meant flashing of the *labels*
 *                              VERB and NOUN above the digit displays.  But
 *                              no, I've now seen videos of a Block 1 DSKY being
 *                              used, and it's really flashing of the verb and noun
 *                              *digits* themselves, just as it is for Block 2.  So
 *                              I've fixed that.
 *              2023-08-14 JAP  Fixed the COMP FAIL and SCALER FAIL lights
 *                              illuminating instead of the COMP ACTY and TM FAIL
 *                              lights, respectively. Also sped up the VERB/NOUN
 *                              flashing to 0.78125 Hz or 1.28 seconds (640 ms on,
 *                              640 ms off), per the ND-1021041 document and
 *                              relevant schematics. Additionally removed a
 *                              200 ms wait from the packet output code, and fixed
 *                              a warning about an incorrect grid sizer
 *                              alignment object on program startup.
 *              2024-12-27 RSB  Implemented --x, --y,  --half-size and
 *                              AGC_SCALE.  Fixed fuzzy digit images.
 */

#include <sys/types.h>
#ifndef WIN32
#include <sys/socket.h>
#endif
#ifndef MSG_NOSIGNAL
#define MSG_NOSIGNAL 0
#endif
#include <errno.h>
#include <wx/utils.h>
#define TOP_YADSKYB1
#include "yaDSKYb1.h"
extern int
CallSocket(char *hostname, unsigned short portnum);

// Stuff for the timer we use for reading the socket interface.
static char DefaultHostname[] = "localhost";
char *Hostname = DefaultHostname;
static char NonDefaultHostname[129];
#ifdef WIN32
static int StartupDelay = 500;
#else
static int StartupDelay = 0;
#endif
static int VerbNounFlashing = 0;
static int ServerSocket = -1;

void
OutputKeycode(int Keycode);

///////////////////////////////////////////////////////////////////////////////////////
// Some debugging functions

void
MyFrame::setAllNumbers(wxBitmap& bitmap)
{
  Digit1Reg1->SetBitmap(bitmap);
  Digit2Reg1->SetBitmap(bitmap);
  Digit3Reg1->SetBitmap(bitmap);
  Digit4Reg1->SetBitmap(bitmap);
  Digit5Reg1->SetBitmap(bitmap);
  Digit1Reg2->SetBitmap(bitmap);
  Digit2Reg2->SetBitmap(bitmap);
  Digit3Reg2->SetBitmap(bitmap);
  Digit4Reg2->SetBitmap(bitmap);
  Digit5Reg2->SetBitmap(bitmap);
  Digit1Reg3->SetBitmap(bitmap);
  Digit2Reg3->SetBitmap(bitmap);
  Digit3Reg3->SetBitmap(bitmap);
  Digit4Reg3->SetBitmap(bitmap);
  Digit5Reg3->SetBitmap(bitmap);
  digitProgramLeft->SetBitmap(bitmap);
  digitProgramRight->SetBitmap(bitmap);
  digitNounLeft->SetBitmap(bitmap);
  digitNounRight->SetBitmap(bitmap);
  digitVerbLeft->SetBitmap(bitmap);
  digitVerbRight->SetBitmap(bitmap);
  officialVerbLeft = bitmap;
  officialVerbRight = bitmap;
  officialNounLeft = bitmap;
  officialNounRight = bitmap;
}
void
MyFrame::setAllSigns(wxBitmap& bitmap)
{
  PlusMinusReg1->SetBitmap(bitmap);
  PlusMinusReg2->SetBitmap(bitmap);
  PlusMinusReg3->SetBitmap(bitmap);
}

///////////////////////////////////////////////////////////////////////////////////////
// These are the events for the UI.

BEGIN_EVENT_TABLE(MyFrame, wxFrame)
EVT_BUTTON(ID_VERBBUTTON, MyFrame::on_VerbButton_pressed)
EVT_BUTTON(ID_NOUNBUTTON, MyFrame::on_NounButton_pressed)
EVT_BUTTON(ID_PLUSBUTTON, MyFrame::on_PlusButton_pressed)
EVT_BUTTON(ID_MINUSBUTTON, MyFrame::on_MinusButton_pressed)
EVT_BUTTON(ID_ZEROBUTTON, MyFrame::on_ZeroButton_pressed)
EVT_BUTTON(ID_SEVENBUTTON, MyFrame::on_SevenButton_pressed)
EVT_BUTTON(ID_FOURBUTTON, MyFrame::on_FourButton_pressed)
EVT_BUTTON(ID_ONEBUTTON, MyFrame::on_OneButton_pressed)
EVT_BUTTON(ID_EIGHTBUTTON, MyFrame::on_EightButton_pressed)
EVT_BUTTON(ID_FIVEBUTTON, MyFrame::on_FiveButton_pressed)
EVT_BUTTON(ID_TWOBUTTON, MyFrame::on_TwoButton_pressed)
EVT_BUTTON(ID_NINEBUTTON, MyFrame::on_NineButton_pressed)
EVT_BUTTON(ID_SIXBUTTON, MyFrame::on_SixButton_pressed)
EVT_BUTTON(ID_THREEBUTTON, MyFrame::on_ThreeButton_pressed)
EVT_BUTTON(ID_CLEARBUTTON, MyFrame::on_ClearButton_pressed)
EVT_BUTTON(ID_KEYRLSEBUTTON, MyFrame::on_KeyRlseButton_pressed)
EVT_BUTTON(ID_ENTERBUTTON, MyFrame::on_EnterButton_pressed)
EVT_BUTTON(ID_ERRORRESETBUTTON, MyFrame::on_ErrorResetButton_pressed)
EVT_BUTTON(ID_UPTELSWITCH, MyFrame::on_UpTelButton_pressed)
END_EVENT_TABLE();

void
MyFrame::on_VerbButton_pressed(wxCommandEvent &event)
{
  OutputKeycode(021);
}

void
MyFrame::on_NounButton_pressed(wxCommandEvent &event)
{
  OutputKeycode(037);
}

void
MyFrame::on_PlusButton_pressed(wxCommandEvent &event)
{
  OutputKeycode(032);
}

void
MyFrame::on_MinusButton_pressed(wxCommandEvent &event)
{
  OutputKeycode(033);
}

void
MyFrame::on_ZeroButton_pressed(wxCommandEvent &event)
{
  OutputKeycode(020);
}

void
MyFrame::on_OneButton_pressed(wxCommandEvent &event)
{
  OutputKeycode(001);
}

void
MyFrame::on_TwoButton_pressed(wxCommandEvent &event)
{
  OutputKeycode(002);
}

void
MyFrame::on_ThreeButton_pressed(wxCommandEvent &event)
{
  OutputKeycode(003);
}

void
MyFrame::on_FourButton_pressed(wxCommandEvent &event)
{
  OutputKeycode(004);
}

void
MyFrame::on_FiveButton_pressed(wxCommandEvent &event)
{
  OutputKeycode(005);
}

void
MyFrame::on_SixButton_pressed(wxCommandEvent &event)
{
  OutputKeycode(006);
}

void
MyFrame::on_SevenButton_pressed(wxCommandEvent &event)
{
  OutputKeycode(007);
}

void
MyFrame::on_EightButton_pressed(wxCommandEvent &event)
{
  OutputKeycode(010);
}

void
MyFrame::on_NineButton_pressed(wxCommandEvent &event)
{
  OutputKeycode(011);
}

void
MyFrame::on_KeyRlseButton_pressed(wxCommandEvent &event)
{
  OutputKeycode(031);
}

void
MyFrame::on_EnterButton_pressed(wxCommandEvent &event)
{
  OutputKeycode(034);
}

void
MyFrame::on_ErrorResetButton_pressed(wxCommandEvent &event)
{
  OutputKeycode(022);
}

void
MyFrame::on_ClearButton_pressed(wxCommandEvent &event)
{
  OutputKeycode(036);
}

void
MyFrame::on_TestAlarmButton_pressed(wxCommandEvent &event)
{
  // Have no idea what the TEST ALARM button is supposed to do.
  // Probably turn on all the indicator lights and 7-segment
  // displays or something.
  // FIXME
}

void
MyFrame::on_UpTelButton_pressed(wxCommandEvent &event)
{
  UpTelAccept = !UpTelAccept;
  if (UpTelAccept)
    SwitchUpTel->SetBitmapLabel(imageUpTelAccept);
  else
    SwitchUpTel->SetBitmapLabel(imageUpTelBlock);
  // FIXME
}

///////////////////////////////////////////////////////////////////////
// For the socket-interface timer.

//-------------------------------------------------------------------------
// This function is called every PULSE_INTERVAL milliseconds.  It manages
// the server connection, and causes display-updates based on input from
// yaAGC.

void
TimerClass::Notify()
{
  static unsigned char Packet[4];
  static int PacketSize = 0;
  static int FlashCounter = 1, FlashStatus = 0;
  int i;
  unsigned char c;

  if (StartupDelay > 0)
    {
      StartupDelay -= PULSE_INTERVAL;
      return;
    }
  // If the noun/verb-flash flag is set, then flash them.
  if (frame->flashing)
    {
      frame->flashCounter++;
      if (frame->flashCounter >= 640 / PULSE_INTERVAL)
        {
          frame->flashCounter = 0;
          frame->flashStateLit = !frame->flashStateLit;
          if (frame->flashStateLit)
            {
              //frame->labelVerb->SetBitmap(frame->imageVerbLabelOn);
              //frame->labelNoun->SetBitmap(frame->imageNounLabelOn);
              frame->digitVerbLeft->SetBitmap(frame->image7Seg0);
              frame->digitVerbRight->SetBitmap(frame->image7Seg0);
              frame->digitNounLeft->SetBitmap(frame->image7Seg0);
              frame->digitNounRight->SetBitmap(frame->image7Seg0);
            }
          else
            {
              //frame->labelVerb->SetBitmap(frame->imageVerbLabelOff);
              //frame->labelNoun->SetBitmap(frame->imageNounLabelOff);
              frame->digitVerbLeft->SetBitmap(frame->officialVerbLeft);
              frame->digitVerbRight->SetBitmap(frame->officialVerbRight);
              frame->digitNounLeft->SetBitmap(frame->officialNounLeft);
              frame->digitNounRight->SetBitmap(frame->officialNounRight);
            }
        }
    }
  // Try to connect to the server (yaAGC) if not already connected.
  if (ServerSocket == -1)
    {
      ServerSocket = CallSocket(Hostname, Portnum);
      if (ServerSocket != -1)
        printf("yaDSKY is connected.\n");
    }
  if (ServerSocket != -1)
    {
      for (;;)
        {
          i = recv(ServerSocket, (char *) &c, 1, MSG_NOSIGNAL);
          if (i == -1)
            {
              // The conditions i==-1,errno==0 or 9 occur only on Win32,
              // and I'm not sure exactly what they corresponds to---but
              // empirically I find that ignoring them makes no difference
              // to the operation of the program.
              if (errno == EAGAIN || errno == 0 || errno == 9)
                i = 0;
              else
                {
                  printf("yaDSKYb1:  server error %d\n", errno);
                  close(ServerSocket);
                  ServerSocket = -1;
                  break;
                }
            }
          if (i == 0)
            break;
          // This (newer) code will accept any packet signature of the form
          // 00 XX XX XX.
          if (0 == (0xc0 & c))
            PacketSize = 0;
          if (PacketSize != 0 || (0xc0 & c) == 0)
            {
              Packet[PacketSize++] = c;
              if (PacketSize >= 4)
                {
                  ActOnIncomingIO(Packet);
                  PacketSize = 0;
                }
            }
        }
    }
}

void
OutputKeycode(int Keycode)
{
  unsigned char Packet[8];
  int j;
  if (ServerSocket != -1)
    {
      FormIoPacket(0404, 077, Packet); // Mask for lowest 6 data bits.
      FormIoPacket(04, 040 | Keycode, &Packet[4]); // Data.
      j = send(ServerSocket, (const char *) Packet, 8, MSG_NOSIGNAL);
      if (j == SOCKET_ERROR && SOCKET_BROKEN)
        {
          close(ServerSocket);
          ServerSocket = -1;
        }
      else
        {
          FormIoPacket(04, 0, &Packet[4]); // Data.
          j = send(ServerSocket, (const char *) Packet, 8, MSG_NOSIGNAL);
          if (j == SOCKET_ERROR && SOCKET_BROKEN)
            {
              close(ServerSocket);
              ServerSocket = -1;
            }
        }
    }
}

void
whatDigit(int selector, wxBitmap& digit)
{
  switch (selector)
    {
  case 0:
    digit = frame->image7Seg0;
    break;
  case 3:
    digit = frame->image7Seg3;
    break;
  case 15:
    digit = frame->image7Seg15;
    break;
  case 19:
    digit = frame->image7Seg19;
    break;
  case 21:
    digit = frame->image7Seg21;
    break;
  case 25:
    digit = frame->image7Seg25;
    break;
  case 27:
    digit = frame->image7Seg27;
    break;
  case 28:
    digit = frame->image7Seg28;
    break;
  case 29:
    digit = frame->image7Seg29;
    break;
  case 30:
    digit = frame->image7Seg30;
    break;
  case 31:
    digit = frame->image7Seg31;
    break;
  default:
    digit = frame->image7Seg0;
    break;
    }
}

void
setSign(uint8_t selector, wxStaticBitmap *sign)
{
  if (selector == 2)
    sign->SetBitmap(frame->imagePlusMinusPlus);
  else if (selector == 1)
    sign->SetBitmap(frame->imagePlusMinusMinus);
  else
    sign->SetBitmap(frame->imagePlusMinusOff);
}

void
TimerClass::ActOnIncomingIO(unsigned char *Packet)
{
  static uint16_t lastReceived[16] =
    { 0 }, lastOUT1 = 0;
  static uint8_t signs[3] =
    { 0 };
  int Channel, Value, uBit, i;
  // Check to see if the message has a yaAGC signature.  If not,
  // ignore it.  The yaAGC signature is 00 01 10 11 in the
  // 2 most-significant bits of the packet's bytes.  We are
  // guaranteed that the first byte is signed 00, so we don't
  // need to check it.
  if (0x40 != (Packet[1] & 0xc0) || 0x80 != (Packet[2] & 0xc0)
      || 0xc0 != (Packet[3] & 0xc0))
    {
      printf("yaDSKYb1:  illegal packet: %02X %02X %02X %02X\n", Packet[0],
          Packet[1], Packet[2], Packet[3]);
      goto Error;
    }
  if (ParseIoPacket(Packet, &Channel, &Value, &uBit))
    {
      printf("yaDSKYb1:  illegal values: %02X %02X %02X %02X\n", Packet[0],
          Packet[1], Packet[2], Packet[3]);
      goto Error;
    }
  //printf("yaDSKYb1:  received channel=%02o value=%04o ubit=%o\n", Channel,
  //    Value, uBit);
#if 0
  // The following is just a temporary thing I'm using to debug telemetry,
  // and really has nothing to do with the DSKY, and so won't appear in the
  // final program.
  if (Channel == 014)
    {
      static FILE *log = NULL;
      if (log == NULL)
        log = fopen("temp.log", "w");
      if (log != NULL)
        {
          int wordOrder = 1 & (lastOUT1 >> 8);
          // Interpret the data as described on p. 53 of Compleat Sunrise.
          // Note that the actual data does not seem to correspond in any
          // way to that description.
          if (wordOrder)
            fprintf(log, "Data word: %05o\n", Value & 077777);
          else if (00000 == (Value & 076000))
            fprintf(log, "ID word: %04o\n", Value & 01777);
          else if (02000 == (Value & 076000))
            fprintf(log, "Input character word: %s %s KEYCODE=%02o\n",
                (Value & 0100) ? "MARK" : "KEY",
                (Value & 040) ? "UPLINK" : "KBD", (Value & 037));
          else
            fprintf(log, "Relay word: relay=%02o settings=%04o\n",
                017 & (Value >> 11), (Value & 03777));
          fflush(log);
        }
    }
#endif
  if (uBit)
    return;
  if (Channel == 011 && (Value & 037) != (lastOUT1 & 037)) // OUT1
    {
      //printf("yaDSKYb1:  received channel=%02o value=%04o ubit=%o\n", Channel,
      //    Value, uBit);
      lastOUT1 = Value;
      frame->indicatorProgAlm->SetBitmap(
          (0 == (Value & 01)) ? frame->imageProgAlmOff : frame->imageProgAlmOn);
      frame->indicatorComp->SetBitmap(
          (0 == (Value & 02)) ?
              frame->imageCompOff : frame->imageCompOn);
      frame->indicatorKeyRlse->SetBitmap(
          (0 == (Value & 04)) ? frame->imageKeyRlseOff : frame->imageKeyRlseOn);
      frame->indicatorTmFail->SetBitmap(
          (0 == (Value & 010)) ?
              frame->imageTmFailOff : frame->imageTmFailOn);
      frame->indicatorCheckFail->SetBitmap(
          (0 == (Value & 020)) ?
              frame->imageCheckFailOff : frame->imageCheckFailOn);
    }
  else if (Channel == 010) // OUT0
    {
      int relayword = (Value >> 11) & 017;
      int received = Value & 03777;
      int bit11 = (Value >> 10) & 1;
      int bits10_6 = (Value >> 5) & 037;
      int bits5_1 = Value & 037;
      if (received != lastReceived[relayword])
        {
          lastReceived[relayword] = received;
          wxBitmap leftDigit, rightDigit;
          whatDigit(bits10_6, leftDigit);
          whatDigit(bits5_1, rightDigit);
          switch (relayword)
            {
          case 0: // Normal state, implying no change.
            break;
          case 11: //   n/a  MD1  MD2
            frame->digitProgramLeft->SetBitmap(leftDigit);
            frame->digitProgramRight->SetBitmap(rightDigit);
            break;
          case 10: // FLASH  VD1  VD2
            frame->officialVerbLeft = leftDigit;
            frame->officialVerbRight = rightDigit;
            frame->digitVerbLeft->SetBitmap(frame->officialVerbLeft);
            frame->digitVerbRight->SetBitmap(frame->officialVerbRight);
            if (frame->flashing && bit11 == 0)
              {
                printf("Turn flashing off.\n");
                frame->flashing = false;
                frame->flashStateLit = true;
                //frame->labelNoun->SetBitmap(frame->imageNounLabelOn);
                //frame->labelVerb->SetBitmap(frame->imageVerbLabelOn);
                frame->flashCounter = 0;
              }
            else if (!frame->flashing && bit11 != 0)
              {
                printf("Turn flashing on.\n");
                frame->flashing = true;
                frame->flashStateLit = false;
                //frame->labelNoun->SetBitmap(frame->imageNounLabelOff);
                //frame->labelVerb->SetBitmap(frame->imageVerbLabelOff);
                frame->flashCounter = 0;
              }
            break;
          case 9: //    n/a  ND1  ND2
            frame->officialNounLeft = leftDigit;
            frame->officialNounRight = rightDigit;
            frame->digitNounLeft->SetBitmap(frame->officialNounLeft);
            frame->digitNounRight->SetBitmap(frame->officialNounRight);
            break;
          case 8: //  UPACT  n/a R1D1
            frame->indicatorUpTl->SetBitmap(
                bit11 ? frame->imageUptlOn : frame->imageUptlOff);
            frame->Digit1Reg1->SetBitmap(rightDigit);
            break;
          case 7: //   +R1S R1D2 R1D3
            frame->Digit2Reg1->SetBitmap(leftDigit);
            frame->Digit3Reg1->SetBitmap(rightDigit);
            signs[0] = (signs[0] & ~2) | (bit11 << 1);
            setSign(signs[0], frame->PlusMinusReg1);
            break;
          case 6: //   -R1S R1D4 R1D5
            frame->Digit4Reg1->SetBitmap(leftDigit);
            frame->Digit5Reg1->SetBitmap(rightDigit);
            signs[0] = (signs[0] & ~1) | bit11;
            setSign(signs[0], frame->PlusMinusReg1);
            break;
          case 5: //   +R2S R2D1 R2D2
            frame->Digit1Reg2->SetBitmap(leftDigit);
            frame->Digit2Reg2->SetBitmap(rightDigit);
            signs[1] = (signs[1] & ~2) | (bit11 << 1);
            setSign(signs[1], frame->PlusMinusReg2);
            break;
          case 4: //   -R2S R2D3 R2D4
            frame->Digit3Reg2->SetBitmap(leftDigit);
            frame->Digit4Reg2->SetBitmap(rightDigit);
            signs[1] = (signs[1] & ~1) | bit11;
            setSign(signs[1], frame->PlusMinusReg2);
            break;
          case 3: //    n/a R2D5 R3D1
            frame->Digit5Reg2->SetBitmap(leftDigit);
            frame->Digit1Reg3->SetBitmap(rightDigit);
            break;
          case 2: //   +R3S R3D2 R3D3
            frame->Digit2Reg3->SetBitmap(leftDigit);
            frame->Digit3Reg3->SetBitmap(rightDigit);
            signs[2] = (signs[2] & ~2) | (bit11 << 1);
            setSign(signs[2], frame->PlusMinusReg3);
            break;
          case 1: //   -R3S R3D4 R3D5
            frame->Digit4Reg3->SetBitmap(leftDigit);
            frame->Digit5Reg3->SetBitmap(rightDigit);
            signs[2] = (signs[2] & ~1) | bit11;
            setSign(signs[2], frame->PlusMinusReg3);
            break;
          default:
            printf("Unused relayword %05o (%02o %1o %2o %2o)\n", received,
                relayword, bit11, bits10_6, bits5_1);
            break;
            }
        }

    }
  return;
  Error: IoErrorCount++;
}

