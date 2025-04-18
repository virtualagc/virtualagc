// -*- C++ -*- generated by wxGlade 0.6.3 on Tue Mar 10 11:02:18 2009
/*
  Copyright 2009 Ronald S. Burkey <info@sandroid.org>

  This file is part of yaAGC.

  yaAGC is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  yaAGC is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with yaAGC; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

  Filename:	yaTelemetry.h
  Purpose:	Header file for yaTelemetry.cpp.
  Reference:	http://www.ibibio.org/apollo
  Mode:		2009-03-09 RSB.	Began.
  		2009-04-07 RSB	Began adding stuff related to MSK formatting.
  		2025-03-08 RSB	Tied screen width to number of text columns
  				in agc_engine.h.
*/

#include <wx/wx.h>
#include <wx/image.h>
#include <wx/hyperlink.h>
// begin wxGlade: ::dependencies
// end wxGlade


#ifndef YATELEMETRY_H
#define YATELEMETRY_H

#include "../yaAGC/agc_engine.h"

// Screen size.
#define TELEMETRY_ROWS 51
#define TELEMETRY_COLUMNS (4 * DISPLAYED_FIELD_WIDTH + 1)

// begin wxGlade: ::extracode
// end wxGlade


// IDs for widgets that have event handlers.
enum { ID_BIGGER, ID_SMALLER, ID_DECODINGBOX };


class TimerClass: public wxTimer {
public:
    int IoErrorCount;

private:
    virtual void Notify();
    void ActOnIncomingIO (unsigned char *Packet);
};


class SimpleFrameClass: public wxFrame {
public:
    // begin wxGlade: SimpleFrameClass::ids
    // end wxGlade

    SimpleFrameClass(wxWindow* parent, int id, const wxString& title, const wxPoint& pos=wxDefaultPosition, const wxSize& size=wxDefaultSize, long style=wxDEFAULT_FRAME_STYLE);
    void ClearScreen (void);
    TimerClass *Timer;
    //void Print (int x, int y, wxString &Value);
    void FontSize (int Points);
    int MskType, RowsToUse;

private:
    // begin wxGlade: SimpleFrameClass::methods
    void set_properties();
    void do_layout();
    // end wxGlade

public:
    // begin wxGlade: SimpleFrameClass::attributes
    wxStaticBox* sizer_10_staticbox;
    wxButton* Bigger;
    wxButton* Smaller;
    wxRadioBox* DecodingBox;
    wxPanel* panel_1;
    wxStaticText* TextCtrl;
    wxHyperlinkCtrl* documentation;
    // end wxGlade

    DECLARE_EVENT_TABLE()

public:
    virtual void BiggerPressed(wxCommandEvent &event); // wxGlade: <event_handler>
    virtual void SmallerPressed(wxCommandEvent &event); // wxGlade: <event_handler>
    virtual void FormattingBoxEvent(wxCommandEvent &event); // wxGlade: <event_handler>
    void TimerStop(wxCloseEvent& event);
}; // wxGlade: end class

class MainFrameClass: public wxFrame {
public:
    // begin wxGlade: MainFrameClass::ids
    // end wxGlade

    MainFrameClass(wxWindow* parent, int id, const wxString& title, const wxPoint& pos=wxDefaultPosition, const wxSize& size=wxDefaultSize, long style=wxDEFAULT_FRAME_STYLE);
    void ClearScreen (void);
    TimerClass *Timer;
    void Print (int x, int y, wxString &Value);
    void FontSize (int Points);
    void Undecorate (void);
    
private:
    // begin wxGlade: MainFrameClass::methods
    void set_properties();
    void do_layout();
    // end wxGlade
    
protected:
    // begin wxGlade: MainFrameClass::attributes
    wxStaticBitmap* bitmap_1;
    wxStaticBitmap* bitmap_5;
    wxTextCtrl* TextCtrl;
    wxStaticBitmap* bitmap_3;
    wxStaticBitmap* bitmap_2;
    // end wxGlade

    DECLARE_EVENT_TABLE()

public:
    wxString exePath;
    void TimerStop(wxCloseEvent &event);
}; // wxGlade: end class


#endif // YATELEMETRY_H
