/*
 * Copyright 2016 Ronald S. Burkey <info@sandroid.org>
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
 */

#include "yaDSKYb1.h"

///////////////////////////////////////////////////////////////////////////////////////
// Some debugging functions

void MyFrame::setAllNumbers(wxBitmap& bitmap)
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
}
void MyFrame::setAllSigns(wxBitmap& bitmap)
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


void MyFrame::on_VerbButton_pressed(wxCommandEvent &event)
{
  wxMessageBox("VERB");
}

void  MyFrame::on_NounButton_pressed(wxCommandEvent &event)
{
  wxMessageBox("NOUN");
}

void  MyFrame::on_PlusButton_pressed(wxCommandEvent &event)
{
  setAllSigns(imagePlusMinusPlus);
}

void  MyFrame::on_MinusButton_pressed(wxCommandEvent &event)
{
  setAllSigns(imagePlusMinusMinus);
}

void  MyFrame::on_ZeroButton_pressed(wxCommandEvent &event)
{
  setAllNumbers(image7Seg21);
}

void  MyFrame::on_OneButton_pressed(wxCommandEvent &event)
{
  setAllNumbers(image7Seg3);
}

void  MyFrame::on_TwoButton_pressed(wxCommandEvent &event)
{
  setAllNumbers(image7Seg25);
}

void  MyFrame::on_ThreeButton_pressed(wxCommandEvent &event)
{
  setAllNumbers(image7Seg27);
}

void  MyFrame::on_FourButton_pressed(wxCommandEvent &event)
{
  setAllNumbers(image7Seg15);
}

void  MyFrame::on_FiveButton_pressed(wxCommandEvent &event)
{
  setAllNumbers(image7Seg30);
}

void  MyFrame::on_SixButton_pressed(wxCommandEvent &event)
{
  setAllNumbers(image7Seg28);
}

void  MyFrame::on_SevenButton_pressed(wxCommandEvent &event)
{
  setAllNumbers(image7Seg19);
}

void  MyFrame::on_EightButton_pressed(wxCommandEvent &event)
{
  setAllNumbers(image7Seg29);
}

void  MyFrame::on_NineButton_pressed(wxCommandEvent &event)
{
  setAllNumbers(image7Seg31);
}

void  MyFrame::on_KeyRlseButton_pressed(wxCommandEvent &event)
{
  wxMessageBox("Key\nRlse");
}

void  MyFrame::on_EnterButton_pressed(wxCommandEvent &event)
{
  indicatorCompFail->SetBitmap(imageCompFailOn);
  indicatorCheckFail->SetBitmap(imageCheckFailOn);
  indicatorComp->SetBitmap(imageCompOn);
  indicatorUpTl->SetBitmap(imageUptlOn);
}

void  MyFrame::on_ErrorResetButton_pressed(wxCommandEvent &event)
{
  indicatorCompFail->SetBitmap(imageCompFailOff);
  indicatorCheckFail->SetBitmap(imageCheckFailOff);
  indicatorComp->SetBitmap(imageCompOff);
  indicatorUpTl->SetBitmap(imageUptlOff);
}

void  MyFrame::on_ClearButton_pressed(wxCommandEvent &event)
{
  setAllNumbers(image7Seg0);
  setAllSigns(imagePlusMinusOff);
}

void  MyFrame::on_UpTelButton_pressed(wxCommandEvent &event)
{
  UpTelAccept = !UpTelAccept;
  if (UpTelAccept) SwitchUpTel->SetBitmapLabel(imageUpTelAccept);
  else SwitchUpTel->SetBitmapLabel(imageUpTelBlock);
}

