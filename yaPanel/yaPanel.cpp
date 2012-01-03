/*
 * Copyright 2011,2012 Ronald S. Burkey <info@sandroid.org>
 *
 * This file is part of yaAGC.
 *
 * yaAGC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * yaAGC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with yaAGC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * Filename:    yaOBC.c
 * Purpose:     Emulator for Gemini peripherals MDR, MDK, IVI,
 *              PCDP, TRS, for use with yaOBC CPU emulator.
 * Compiler:    GNU gcc.
 * Reference:   http://www.ibibio.org/apollo
 * Mods:        2011-12-30 RSB  Began.
 *              2011-01-01 RSB  All of the input controls seem to
 *                              be present and working, in so
 *                              far as superficial appearance is
 *                              concerned.  (The don't affect
 *                              yaOBC yet.)  No outputs do anything
 *                              as of yet.
 *              2012-01-02 RSB  All of the outputs working now, and
 *                              checked with DEBUG_WIDGETS.  Still
 *                              no actual code for connecting to
 *                              yaOBC.
 *
 * This is a wxWidgets-based program.  It is unlike the previous
 * wxWidgets-based programs in the yaAGC project (yaDSKY, yaDEDA,
 * etc.) in a couple of important ways:
 *
 *   1. Rather than being created with the help of a RAD
 *      code-generator such as wxGlade, it's all hand-coded.
 *   2. The UI is simply a background PNG with mouse-events
 *      captured and additional PNGs composited onto the
 *      background PNG when needed. Whereas, the prior programs
 *      created the background using a complicated mixture of
 *      sizers, static images, and bitmap-button widgets.
 *
 * These two ideas go together, because it's the relative simplicity
 * of the latter that allows the former.  The relative simplicity of
 * the new approach over that old provides an advantage in terms of
 * resizing the UI, which was very limited before, but completely
 * flexible now.  The positions of all input fields and output
 * widgets are defined in the file yaPanel.coordinates, which is
 * read in at runtime, rather than hard-coded into the program.
 */

#include <wx/wx.h>
#include <wx/sizer.h>
#include <wx/timer.h>
#include "time.h"

// Just for testing output widgets.  Comment out to get normal functionality.
#define DEBUG_WIDGETS
#ifdef DEBUG_WIDGETS
int DebugPosn = 0;
int DebugDspn = 0;
#define DEBUG_POSN(n) DebugPosn = n;
#define DEBUG_DSPN(n) DebugDspn = n;
#else
#define DEBUG_POSN(n)
#define DEBUG_DSPN(n)
#endif

#define MAX_COORDINATES 128 // Much more than we actually need.
#define MAX_NAME_SIZE 41
#define NAME_FIELD_WIDTH "40"
int BackgroundWidth;
int BackgroundHeight;

/////////////////////////////////////////////////////////////////////
// This section is devoted to defining input fields or output widgets
// for the UI.  A new field is implemented as follows:
//
//  1.  Defined in yaPanel.coordinates.
//  2.  Corresponding entries must be added to enum FieldIndex_t and
//      Fields[] in this section.
//  3.  Graphics for an output widget have to be added to
//      enum GraphicIndex_t and Graphics[] in this section.
//  4.  Default values for stateful outputs may need to be added to
//      the wxImagePanel() constructor.
//  5.  Actions for the input fields must be added to the
//      leftDown() event handler.
//  6.  Spring-loaded output widgets have to be added to the list
//      in the leftUp() event handler.

// Symbolic names for the field-types defined in yaPanel.coordinates.
// Don't change the order of these, unless doing so consistently with
// the ordering in the initializers for the Fields[] array.
enum FieldIndex_t
{
  mdr_digit_1 = 0,
  mdr_digit_2,
  mdr_digit_3,
  mdr_digit_4,
  mdr_digit_5,
  mdr_digit_6,
  mdr_digit_7,
  mdr_power,
  mdr_power_on,
  mdr_power_off,
  mdr_readout,
  mdr_clear,
  mdr_enter,
  mdk_digit_zero,
  mdk_digit_1,
  mdk_digit_2,
  mdk_digit_3,
  mdk_digit_4,
  mdk_digit_5,
  mdk_digit_6,
  mdk_digit_7,
  mdk_digit_8,
  mdk_digit_9,
  ivi_indicator1_fwd,
  ivi_indicator1_aft,
  ivi_indicator2_l,
  ivi_indicator2_r,
  ivi_indicator3_up,
  ivi_indicator3_dn,
  ivi_digits1_1,
  ivi_digits1_2,
  ivi_digits1_3,
  ivi_digits2_1,
  ivi_digits2_2,
  ivi_digits2_3,
  ivi_digits3_1,
  ivi_digits3_2,
  ivi_digits3_3,
  ivi_rotary1,
  ivi_rotary2,
  ivi_rotary3,
  ivi_rotary1_aft,
  ivi_rotary1_fwd,
  ivi_rotary2_l,
  ivi_rotary2_r,
  ivi_rotary3_dn,
  ivi_rotary3_up,
  pcdp_indicator_comp,
  pcdp_indicator_malf,
  pcdp_power,
  pcdp_rotary,
  pcdp_start,
  pcdp_reset,
  pcdp_power_on,
  pcdp_power_off,
  pcdp_rotary_rndz,
  pcdp_rotary_ctchup,
  pcdp_rotary_asc,
  pcdp_rotary_pre_ln,
  pcdp_rotary_td,
  pcdp_rotary_pre_re_ent,
  trs_et_toggle1,
  trs_et_toggle2,
  trs_et_rotary,
  trs_et_digit_1,
  trs_et_digit_2,
  trs_et_digit_3,
  trs_et_digit_4,
  trs_et_toggle1_stby,
  trs_et_toggle1_stop,
  debug_spring_1,
  trs_et_toggle2_up = debug_spring_1,
  trs_et_toggle2_dn,
  debug_dial_1,
  trs_et_rotary_decr_3 = debug_dial_1,
  trs_et_rotary_decr_2,
  trs_et_rotary_decr_1,
  trs_et_rotary_0,
  trs_et_rotary_incr_1,
  trs_et_rotary_incr_2,
  trs_et_rotary_incr_3,
  trs_metdc_toggle,
  trs_metdc_rotary,
  trs_metdc_digit_1,
  trs_metdc_digit_2,
  trs_metdc_digit_3,
  trs_metdc_digit_4,
  trs_metdc_digit_5,
  trs_metdc_digit_6,
  trs_metdc_digit_7,
  trs_metdc_toggle_start,
  trs_metdc_toggle_stop,
  debug_dial_2,
  trs_metdc_rotary_decr_3 = debug_dial_2,
  trs_metdc_rotary_decr_2,
  trs_metdc_rotary_decr_1,
  trs_metdc_rotary_0,
  trs_metdc_rotary_incr_1,
  trs_metdc_rotary_incr_2,
  trs_metdc_rotary_incr_3,
  trs_ac_hands,
  trs_ac_set
};
// Symbolic names for the graphics files used for widgets.
// Don't change the order of these, unless done consistently
// with the Graphics[] array.
enum GraphicIndex_t
{
  gi_none = 0,
  ivi_rotary_middle,
  ivi_rotary_right,
  ivi_rotary_left,
  ivi_disp_digit_blank,
  ivi_disp_digit_0,
  ivi_disp_digit_1,
  ivi_disp_digit_2,
  ivi_disp_digit_3,
  ivi_disp_digit_4,
  ivi_disp_digit_5,
  ivi_disp_digit_6,
  ivi_disp_digit_7,
  ivi_disp_digit_8,
  ivi_disp_digit_9,
  ivi_indicator1_aft_off,
  ivi_indicator1_aft_on,
  ivi_indicator1_fwd_off,
  ivi_indicator1_fwd_on,
  ivi_indicator2_l_off,
  ivi_indicator2_l_on,
  ivi_indicator2_r_off,
  ivi_indicator2_r_on,
  ivi_indicator3_up_off,
  ivi_indicator3_up_on,
  ivi_indicator3_dn_off,
  ivi_indicator3_dn_on,
  mdk_digit_zero_pressed,
  mdk_digit_1_pressed,
  mdk_digit_2_pressed,
  mdk_digit_3_pressed,
  mdk_digit_4_pressed,
  mdk_digit_5_pressed,
  mdk_digit_6_pressed,
  mdk_digit_7_pressed,
  mdk_digit_8_pressed,
  mdk_digit_9_pressed,
  mdr_clear_pressed,
  mdr_enter_pressed,
  mdr_readout_pressed,
  mdr_disp_digit_blank,
  mdr_disp_digit_0,
  mdr_disp_digit_1,
  mdr_disp_digit_2,
  mdr_disp_digit_3,
  mdr_disp_digit_4,
  mdr_disp_digit_5,
  mdr_disp_digit_6,
  mdr_disp_digit_7,
  mdr_disp_digit_8,
  mdr_disp_digit_9,
  pcdp_rotary_0,
  pcdp_rotary_1,
  pcdp_rotary_2,
  pcdp_rotary_3,
  pcdp_rotary_4,
  pcdp_rotary_5,
  pcdp_rotary_6,
  pcdp_rotary_7,
  pcdp_start_pressed,
  pcdp_reset_pressed,
  pcdp_indicator_comp_on,
  pcdp_indicator_comp_off,
  pcdp_indicator_malf_on,
  pcdp_indicator_malf_off,
  toggle_middle,
  toggle_up,
  toggle_down,
  trs_ac_hands_hours,
  trs_ac_hands_minutes,
  trs_ac_hands_seconds,
  trs_ac_set_pressed,
  trs_et_rotary_middle,
  trs_et_rotary_right1,
  trs_et_rotary_right2,
  trs_et_rotary_right3,
  trs_et_rotary_left1,
  trs_et_rotary_left2,
  trs_et_rotary_left3,
  trs_metdc_rotary_middle,
  trs_metdc_rotary_right1,
  trs_metdc_rotary_right2,
  trs_metdc_rotary_right3,
  trs_metdc_rotary_left1,
  trs_metdc_rotary_left2,
  trs_metdc_rotary_left3,
  trs_disp_digit_blank,
  trs_disp_digit_0,
  trs_disp_digit_1,
  trs_disp_digit_2,
  trs_disp_digit_3,
  trs_disp_digit_4,
  trs_disp_digit_5,
  trs_disp_digit_6,
  trs_disp_digit_7,
  trs_disp_digit_8,
  trs_disp_digit_9

};
enum FieldType_t
{
  FT_NONE = 0, FT_IN, FT_OUT
};
typedef struct
{
  char Name[MAX_NAME_SIZE];
  enum FieldType_t Type; // FT_IN or FT_OUT.
  // FT_OUT only.
  int x, y;
  enum GraphicIndex_t State;
  // FT_IN only.
  int Left, Right, Top, Bottom;
} Field_t;
typedef struct
{
  char Name[MAX_NAME_SIZE];
  wxImage *UnscaledImage;
  wxImage *ScaledImage;
} Graphic_t;
// Initialize in the same order as enum FieldType_t.
// In other words, access as ImageFields[enum FieldType_t].
Field_t Fields[] =
  {
    { "mdr-digit-1" },
    { "mdr-digit-2" },
    { "mdr-digit-3" },
    { "mdr-digit-4" },
    { "mdr-digit-5" },
    { "mdr-digit-6" },
    { "mdr-digit-7" },
    { "mdr-power" },
    { "mdr-power-on" },
    { "mdr-power-off" },
    { "mdr-readout" },
    { "mdr-clear" },
    { "mdr-enter" },
    { "mdk-digit-zero" },
    { "mdk-digit-1" },
    { "mdk-digit-2" },
    { "mdk-digit-3" },
    { "mdk-digit-4" },
    { "mdk-digit-5" },
    { "mdk-digit-6" },
    { "mdk-digit-7" },
    { "mdk-digit-8" },
    { "mdk-digit-9" },
    { "ivi-indicator1-fwd" },
    { "ivi-indicator1-aft" },
    { "ivi-indicator2-l" },
    { "ivi-indicator2-r" },
    { "ivi-indicator3-up" },
    { "ivi-indicator3-dn" },
    { "ivi-digits1-1" },
    { "ivi-digits1-2" },
    { "ivi-digits1-3" },
    { "ivi-digits2-1" },
    { "ivi-digits2-2" },
    { "ivi-digits2-3" },
    { "ivi-digits3-1" },
    { "ivi-digits3-2" },
    { "ivi-digits3-3" },
    { "ivi-rotary1" },
    { "ivi-rotary2" },
    { "ivi-rotary3" },
    { "ivi-rotary1-aft" },
    { "ivi-rotary1-fwd" },
    { "ivi-rotary2-l" },
    { "ivi-rotary2-r" },
    { "ivi-rotary3-dn" },
    { "ivi-rotary3-up" },
    { "pcdp-indicator-comp" },
    { "pcdp-indicator-malf" },
    { "pcdp-power" },
    { "pcdp-rotary" },
    { "pcdp-start" },
    { "pcdp-reset" },
    { "pcdp-power-on" },
    { "pcdp-power-off" },
    { "pcdp-rotary-rndz" },
    { "pcdp-rotary-ctchup" },
    { "pcdp-rotary-asc" },
    { "pcdp-rotary-pre-ln" },
    { "pcdp-rotary-td" },
    { "pcdp-rotary-pre-re-ent" },
    { "trs-et-toggle1" },
    { "trs-et-toggle2" },
    { "trs-et-rotary" },
    { "trs-et-digit-1" },
    { "trs-et-digit-2" },
    { "trs-et-digit-3" },
    { "trs-et-digit-4" },
    { "trs-et-toggle1-stby" },
    { "trs-et-toggle1-stop" },
    { "trs-et-toggle2-up" },
    { "trs-et-toggle2-dn" },
    { "trs-et-rotary-decr-3" },
    { "trs-et-rotary-decr-2" },
    { "trs-et-rotary-decr-1" },
    { "trs-et-rotary-0" },
    { "trs-et-rotary-incr-1" },
    { "trs-et-rotary-incr-2" },
    { "trs-et-rotary-incr-3" },
    { "trs-metdc-toggle" },
    { "trs-metdc-rotary" },
    { "trs-metdc-digit-1" },
    { "trs-metdc-digit-2" },
    { "trs-metdc-digit-3" },
    { "trs-metdc-digit-4" },
    { "trs-metdc-digit-5" },
    { "trs-metdc-digit-6" },
    { "trs-metdc-digit-7" },
    { "trs-metdc-toggle-start" },
    { "trs-metdc-toggle-stop" },
    { "trs-metdc-rotary-decr-3" },
    { "trs-metdc-rotary-decr-2" },
    { "trs-metdc-rotary-decr-1" },
    { "trs-metdc-rotary-0" },
    { "trs-metdc-rotary-incr-1" },
    { "trs-metdc-rotary-incr-2" },
    { "trs-metdc-rotary-incr-3" },
    { "trs-ac-hands" },
    { "trs-ac-set" } };
int NumFields = (sizeof(Fields) / sizeof(Fields[0]));
// Initialize in same order as GraphicIndex_t;
Graphic_t Graphics[] =
  {
    { "dummy" },
    { "ivi-rotary-middle.png" },
    { "ivi-rotary-right.png" },
    { "ivi-rotary-left.png" },
    { "ivi-disp-digit-blank.png" },
    { "ivi-disp-digit-0.png" },
    { "ivi-disp-digit-1.png" },
    { "ivi-disp-digit-2.png" },
    { "ivi-disp-digit-3.png" },
    { "ivi-disp-digit-4.png" },
    { "ivi-disp-digit-5.png" },
    { "ivi-disp-digit-6.png" },
    { "ivi-disp-digit-7.png" },
    { "ivi-disp-digit-8.png" },
    { "ivi-disp-digit-9.png" },
    { "ivi-indicator1-aft-off.png" },
    { "ivi-indicator1-aft-on.png" },
    { "ivi-indicator1-fwd-off.png" },
    { "ivi-indicator1-fwd-on.png" },
    { "ivi-indicator2-l-off.png" },
    { "ivi-indicator2-l-on.png" },
    { "ivi-indicator2-r-off.png" },
    { "ivi-indicator2-r-on.png" },
    { "ivi-indicator3-up-off.png" },
    { "ivi-indicator3-up-on.png" },
    { "ivi-indicator3-dn-off.png" },
    { "ivi-indicator3-dn-on.png" },
    { "mdk-digit-zero-pressed.png" },
    { "mdk-digit-1-pressed.png" },
    { "mdk-digit-2-pressed.png" },
    { "mdk-digit-3-pressed.png" },
    { "mdk-digit-4-pressed.png" },
    { "mdk-digit-5-pressed.png" },
    { "mdk-digit-6-pressed.png" },
    { "mdk-digit-7-pressed.png" },
    { "mdk-digit-8-pressed.png" },
    { "mdk-digit-9-pressed.png" },
    { "mdr-clear-pressed.png" },
    { "mdr-enter-pressed.png" },
    { "mdr-readout-pressed.png" },
    { "mdr-disp-digit-blank.png" },
    { "mdr-disp-digit-0.png" },
    { "mdr-disp-digit-1.png" },
    { "mdr-disp-digit-2.png" },
    { "mdr-disp-digit-3.png" },
    { "mdr-disp-digit-4.png" },
    { "mdr-disp-digit-5.png" },
    { "mdr-disp-digit-6.png" },
    { "mdr-disp-digit-7.png" },
    { "mdr-disp-digit-8.png" },
    { "mdr-disp-digit-9.png" },
    { "pcdp-rotary-0.png" },
    { "pcdp-rotary-1.png" },
    { "pcdp-rotary-2.png" },
    { "pcdp-rotary-3.png" },
    { "pcdp-rotary-4.png" },
    { "pcdp-rotary-5.png" },
    { "pcdp-rotary-6.png" },
    { "pcdp-rotary-7.png" },
    { "pcdp-start-pressed.png" },
    { "pcdp-reset-pressed.png" },
    { "pcdp-indicator-comp-on.png" },
    { "pcdp-indicator-comp-off.png" },
    { "pcdp-indicator-malf-on.png" },
    { "pcdp-indicator-malf-off.png" },
    { "toggle-middle.png" },
    { "toggle-up.png" },
    { "toggle-down.png" },
    { "trs-ac-hands-hours.png" },
    { "trs-ac-hands-minutes.png" },
    { "trs-ac-hands-seconds.png" },
    { "trs-ac-set-pressed.png" },
    { "trs-et-rotary-middle.png" },
    { "trs-et-rotary-right1.png" },
    { "trs-et-rotary-right2.png" },
    { "trs-et-rotary-right3.png" },
    { "trs-et-rotary-left1.png" },
    { "trs-et-rotary-left2.png" },
    { "trs-et-rotary-left3.png" },
    { "trs-metdc-rotary-middle.png" },
    { "trs-metdc-rotary-right1.png" },
    { "trs-metdc-rotary-right2.png" },
    { "trs-metdc-rotary-right3.png" },
    { "trs-metdc-rotary-left1.png" },
    { "trs-metdc-rotary-left2.png" },
    { "trs-metdc-rotary-left3.png" },
    { "trs-disp-digit-blank.png" },
    { "trs-disp-digit-0.png" },
    { "trs-disp-digit-1.png" },
    { "trs-disp-digit-2.png" },
    { "trs-disp-digit-3.png" },
    { "trs-disp-digit-4.png" },
    { "trs-disp-digit-5.png" },
    { "trs-disp-digit-6.png" },
    { "trs-disp-digit-7.png" },
    { "trs-disp-digit-8.png" },
    { "trs-disp-digit-9.png" }, };
int NumGraphics = (sizeof(Graphics) / sizeof(Graphics[0]));
#define MAX_CLOCK_ANGLES 120
Graphic_t HandsHours[MAX_CLOCK_ANGLES], HandsMinutes[MAX_CLOCK_ANGLES],
    HandsSeconds[MAX_CLOCK_ANGLES];

/////////////////////////////////////////////////////////////////////

class wxImagePanel : public wxPanel
{
  wxImage image;
  wxBitmap resized, widget;
  int w, h;
  int xLeftDown, yLeftDown, WidgetIndex;
  wxTimer *Timer;

public:
  wxImagePanel(wxFrame* parent, wxString file, wxBitmapType format);
  void
  ButtonIsPressed(enum GraphicIndex_t Index);
  //void
  //Composite(wxImage *Image, int x, int y);
  void
  BufferedComposite(wxMemoryDC *dc, wxImage *Image, int x, int y);
  void
  Rescale(wxImage *Unscaled, wxImage *Scaled);

  void
  paintEvent(wxPaintEvent & evt);
  void
  paintNow();
  void
  OnSize(wxSizeEvent& event);
  void
  render(wxDC& dc);

  // some useful events
  void
  leftDown(wxMouseEvent& event);
  void
  leftUp(wxMouseEvent& event);
  void
  rightClick(wxMouseEvent& event);
  void
  TimerEvent(wxTimerEvent& event);
  /*
   void mouseMoved(wxMouseEvent& event);
   void mouseDown(wxMouseEvent& event);
   void mouseWheelMoved(wxMouseEvent& event);
   void mouseReleased(wxMouseEvent& event);
   void mouseLeftWindow(wxMouseEvent& event);
   void keyPressed(wxKeyEvent& event);
   void keyReleased(wxKeyEvent& event);
   */

DECLARE_EVENT_TABLE ()
};

BEGIN_EVENT_TABLE(wxImagePanel, wxPanel)
// some useful events
EVT_LEFT_DOWN(wxImagePanel::leftDown)
EVT_LEFT_UP(wxImagePanel::leftUp)
EVT_RIGHT_DOWN(wxImagePanel::rightClick)
/*
 EVT_MOTION(wxImagePanel::mouseMoved)
 EVT_LEAVE_WINDOW(wxImagePanel::mouseLeftWindow)
 EVT_KEY_DOWN(wxImagePanel::keyPressed)
 EVT_KEY_UP(wxImagePanel::keyReleased)
 EVT_MOUSEWHEEL(wxImagePanel::mouseWheelMoved)
 */

EVT_TIMER(12345, wxImagePanel::TimerEvent)

// catch paint events
EVT_PAINT(wxImagePanel::paintEvent)
//Size event
EVT_SIZE(wxImagePanel::OnSize)
END_EVENT_TABLE();

// some useful events
/*
 void wxImagePanel::mouseMoved(wxMouseEvent& event) {}
 void wxImagePanel::mouseDown(wxMouseEvent& event) {}
 void wxImagePanel::mouseWheelMoved(wxMouseEvent& event) {}
 void wxImagePanel::mouseReleased(wxMouseEvent& event) {}
 void wxImagePanel::rightClick(wxMouseEvent& event) {}
 void wxImagePanel::mouseLeftWindow(wxMouseEvent& event) {}
 void wxImagePanel::keyPressed(wxKeyEvent& event) {}
 void wxImagePanel::keyReleased(wxKeyEvent& event) {}
 */

void
wxImagePanel::TimerEvent(wxTimerEvent& event)
{
  wxPaintDC dc(this);
  render(dc);
}

wxImagePanel::wxImagePanel(wxFrame* parent, wxString file, wxBitmapType format) :
  wxPanel(parent)
{
  // load the file... ideally add a check to see if loading was successful
  image.LoadFile(file, format);
  w = -1;
  h = -1;
  // Load all widget images.
  int i;
  for (i = 1; i < NumGraphics; i++)
    {
      wxString Filename = wxString((char *) Graphics[i].Name, wxConvUTF8);
      Graphics[i].UnscaledImage = new wxImage(Filename, wxBITMAP_TYPE_PNG);
      Graphics[i].ScaledImage = new wxImage(100, 100);
    }
  // Default settings for the various outputs that need them
  // here.  Things like momentary pushbuttons don't need defaults,
  // but stateful widgets like toggles and rotaries do.
  Fields[mdr_power].State = toggle_down;
  Fields[ivi_rotary1].State = ivi_rotary_middle;
  Fields[ivi_rotary2].State = ivi_rotary_middle;
  Fields[ivi_rotary3].State = ivi_rotary_middle;
  Fields[ivi_indicator1_aft].State = ivi_indicator1_aft_off;
  Fields[ivi_indicator1_fwd].State = ivi_indicator1_fwd_off;
  Fields[ivi_indicator2_l].State = ivi_indicator2_l_off;
  Fields[ivi_indicator2_r].State = ivi_indicator2_r_off;
  Fields[ivi_indicator3_up].State = ivi_indicator3_up_off;
  Fields[ivi_indicator3_dn].State = ivi_indicator3_dn_off;
  Fields[pcdp_power].State = toggle_down;
  Fields[pcdp_rotary].State = pcdp_rotary_5;
  Fields[pcdp_indicator_comp].State = pcdp_indicator_comp_off;
  Fields[pcdp_indicator_malf].State = pcdp_indicator_malf_off;
  Fields[trs_et_toggle1].State = toggle_middle;
  Fields[trs_et_toggle2].State = toggle_middle;
  Fields[trs_et_rotary].State = trs_et_rotary_middle;
  Fields[trs_metdc_toggle].State = toggle_middle;
  Fields[trs_metdc_rotary].State = trs_metdc_rotary_middle;

  // Produce all of the necessary rotations of the clock hands.
  for (i = 0; i < MAX_CLOCK_ANGLES; i++)
    {
      double Angle = -i * 2 * 3.1415926535 / MAX_CLOCK_ANGLES;
      wxPoint Center;
      wxImage *Source, **Dest;
      Source = Graphics[trs_ac_hands_hours].UnscaledImage;
      HandsHours[i].ScaledImage = new wxImage(64, 64);
      Dest = &HandsHours[i].UnscaledImage;
      *Dest = new wxImage(64, 64);
      Center.x = (Source->GetWidth() + 1) / 2;
      Center.y = (Source->GetHeight() + 1) / 2;
      **Dest = Source->Rotate(Angle, Center);

      Source = Graphics[trs_ac_hands_minutes].UnscaledImage;
      HandsMinutes[i].ScaledImage = new wxImage(64, 64);
      Dest = &HandsMinutes[i].UnscaledImage;
      *Dest = new wxImage(64, 64);
      Center.x = (Source->GetWidth() + 1) / 2;
      Center.y = (Source->GetHeight() + 1) / 2;
      **Dest = Source->Rotate(Angle, Center);

      Source = Graphics[trs_ac_hands_seconds].UnscaledImage;
      HandsSeconds[i].ScaledImage = new wxImage(64, 64);
      Dest = &HandsSeconds[i].UnscaledImage;
      *Dest = new wxImage(64, 64);
      Center.x = (Source->GetWidth() + 1) / 2;
      Center.y = (Source->GetHeight() + 1) / 2;
      **Dest = Source->Rotate(Angle, Center);
    }

  Timer = new wxTimer(this, 12345);
  Timer->Start(1000);
}

// Mouse events.

void
wxImagePanel::leftDown(wxMouseEvent& event)
{
  int Width, Height, x, y, i;
  wxString Message, ConvertedName;

  // Get the mouse coordinates, adjusted to background-image
  // coordinates.
  //GetSize(&Width, &Height);
  Width = w;
  Height = h;
  x = (BackgroundWidth * event.GetX() + Width / 2) / Width;
  y = (BackgroundHeight * event.GetY() + Height / 2) / Height;
  xLeftDown = x;
  yLeftDown = y;

  // Search the input fields.
  WidgetIndex = -1;
  for (i = 0; i < NumFields; i++)
    if (Fields[i].Type == FT_IN && x >= Fields[i].Left && x <= Fields[i].Right
        && y >= Fields[i].Top && y <= Fields[i].Bottom)
      break;

  if (i < NumFields)
    {
      int ReRender = 0;
      WidgetIndex = i;
      //ConvertedName = wxString::FromAscii(InputFields[i].Name);
      //Message = wxT("Left-click at input field ") + ConvertedName;
      //wxMessageBox(Message, wxT("FYI"), wxOK);
      switch (WidgetIndex)
        {
      case mdk_digit_zero:
        ButtonIsPressed(mdk_digit_zero_pressed);
        DEBUG_POSN(0)
#ifdef DEBUG_WIDGETS
        // Clear all debug-displays.
        // MDR digits.
        for (i = 0; i < 7; i++)
          Fields[mdr_digit_1 + i].State = mdr_disp_digit_blank;
        // IVI digits.
        for (i = 0; i < 9; i++)
          Fields[ivi_digits1_1 + i].State = ivi_disp_digit_blank;
        // TRS digits.
        for (i = 0; i < 4; i++)
          Fields[trs_et_digit_1 + i].State = trs_disp_digit_blank;
        for (i = 0; i < 7; i++)
          Fields[trs_metdc_digit_1 + i].State = trs_disp_digit_blank;
#endif
        ;
        break;
      case mdk_digit_1:
        ButtonIsPressed(mdk_digit_1_pressed);
        DEBUG_POSN(0)
        ;
        break;
      case mdk_digit_2:
        ButtonIsPressed(mdk_digit_2_pressed);
        DEBUG_POSN(1)
        ;
        break;
      case mdk_digit_3:
        ButtonIsPressed(mdk_digit_3_pressed);
        DEBUG_POSN(2)
        ;
        break;
      case mdk_digit_4:
        ButtonIsPressed(mdk_digit_4_pressed);
        DEBUG_POSN(3)
        ;
        break;
      case mdk_digit_5:
        ButtonIsPressed(mdk_digit_5_pressed);
        DEBUG_POSN(4)
        ;
        break;
      case mdk_digit_6:
        ButtonIsPressed(mdk_digit_6_pressed);
        DEBUG_POSN(5)
        ;
        break;
      case mdk_digit_7:
        ButtonIsPressed(mdk_digit_7_pressed);
        DEBUG_POSN(6)
        ;
        break;
      case mdk_digit_8:
        ButtonIsPressed(mdk_digit_8_pressed);
        DEBUG_POSN(7)
        ;
        break;
      case mdk_digit_9:
        ButtonIsPressed(mdk_digit_9_pressed);
        DEBUG_POSN(8)
        ;
        break;
      case mdr_readout:
        ButtonIsPressed(mdr_readout_pressed);
        break;
      case mdr_clear:
        ButtonIsPressed(mdr_clear_pressed);
        break;
      case mdr_enter:
        ButtonIsPressed(mdr_enter_pressed);
        break;
      case pcdp_start:
        ButtonIsPressed(pcdp_start_pressed);
        break;
      case pcdp_reset:
        ButtonIsPressed(pcdp_reset_pressed);
        break;
      case trs_ac_set:
        ButtonIsPressed(trs_ac_set_pressed);
        break;
      case mdr_power_on:
        ReRender = 1;
        Fields[mdr_power].State = toggle_up;
        break;
      case mdr_power_off:
        ReRender = 1;
        Fields[mdr_power].State = toggle_down;
        break;
      case pcdp_power_on:
        ReRender = 1;
        Fields[pcdp_power].State = toggle_up;
        break;
      case pcdp_power_off:
        ReRender = 1;
        Fields[pcdp_power].State = toggle_down;
        break;
      case trs_et_toggle1_stby:
        ReRender = 1;
        Fields[trs_et_toggle1].State = toggle_up;
        break;
      case trs_et_toggle1_stop:
        ReRender = 1;
        Fields[trs_et_toggle1].State = toggle_down;
        break;
      case trs_et_toggle2_up:
        ReRender = 1;
        Fields[trs_et_toggle2].State = toggle_up;
#ifdef DEBUG_WIDGETS
        //Message.Printf (wxT ("dspn=%d posn=%d"), DebugDspn, DebugPosn);
        //wxMessageBox (Message, wxT ("Debug"));
        enum GraphicIndex_t *State;
        switch (DebugDspn)
          {
        case 1: // MDR
          if (DebugPosn < 7)
            {
              State = &Fields[mdr_digit_1 + DebugPosn].State;
              if (*State == gi_none)
                *State = mdr_disp_digit_0;
              else
                *State = (GraphicIndex_t) (*State + 1);
              if (*State > mdr_disp_digit_9)
                *State = mdr_disp_digit_0;
            }
          break;
        case 2: // MDR
          if (DebugPosn < 9)
            {
              State = &Fields[ivi_digits1_1 + DebugPosn].State;
              if (*State == gi_none)
                *State = ivi_disp_digit_0;
              else
                *State = (GraphicIndex_t) (*State + 1);
              if (*State > ivi_disp_digit_9)
                *State = ivi_disp_digit_0;
            }
          break;
        case 3: // TRS E.T.
          if (DebugPosn < 4)
            {
              State = &Fields[trs_et_digit_1 + DebugPosn].State;
              TrsDebugDigits: ;
              if (*State == gi_none)
                *State = trs_disp_digit_0;
              else
                *State = (GraphicIndex_t) (*State + 1);
              if (*State > trs_disp_digit_9)
                *State = trs_disp_digit_0;
            }
          break;
        case 4: // TRS M.E.T.D.C.
          if (DebugPosn < 7)
            {
              State = &Fields[trs_metdc_digit_1 + DebugPosn].State;
              goto TrsDebugDigits;
            }
          break;
        case 5: // PCDP indicators.
          State = &Fields[pcdp_indicator_comp + DebugPosn].State;
          switch (DebugPosn)
            {
          case 0:
            *State
                = (*State == pcdp_indicator_comp_on) ? pcdp_indicator_comp_off
                    : pcdp_indicator_comp_on;
            break;
          case 1:
            *State
                = (*State == pcdp_indicator_malf_on) ? pcdp_indicator_malf_off
                    : pcdp_indicator_malf_on;
            break;
          default:
            break;
            }
          break;
        case 6: // IVI indicators.
          State = &Fields[ivi_indicator1_fwd + DebugPosn].State;
          switch (DebugPosn)
            {
          case 0:
            *State = (*State == ivi_indicator1_fwd_on) ? ivi_indicator1_fwd_off
                : ivi_indicator1_fwd_on;
            break;
          case 1:
            *State = (*State == ivi_indicator1_aft_on) ? ivi_indicator1_aft_off
                : ivi_indicator1_aft_on;
            break;
          case 2:
            *State = (*State == ivi_indicator2_l_on) ? ivi_indicator2_l_off
                : ivi_indicator2_l_on;
            break;
          case 3:
            *State = (*State == ivi_indicator2_r_on) ? ivi_indicator2_r_off
                : ivi_indicator2_r_on;
            break;
          case 4:
            *State = (*State == ivi_indicator3_up_on) ? ivi_indicator3_up_off
                : ivi_indicator3_up_on;
            break;
          case 5:
            *State = (*State == ivi_indicator3_dn_on) ? ivi_indicator3_dn_off
                : ivi_indicator3_dn_on;
            break;
          default:
            break;
            }
          break;
        default:
          break;
          }
#endif
        break;
      case trs_et_toggle2_dn:
        ReRender = 1;
        Fields[trs_et_toggle2].State = toggle_down;
        break;
      case trs_metdc_toggle_start:
        ReRender = 1;
        Fields[trs_metdc_toggle].State = toggle_up;
        break;
      case trs_metdc_toggle_stop:
        ReRender = 1;
        Fields[trs_metdc_toggle].State = toggle_down;
        break;
      case ivi_rotary1_aft:
        ReRender = 1;
        Fields[ivi_rotary1].State = ivi_rotary_left;
        break;
      case ivi_rotary1_fwd:
        ReRender = 1;
        Fields[ivi_rotary1].State = ivi_rotary_right;
        break;
      case ivi_rotary2_l:
        ReRender = 1;
        Fields[ivi_rotary2].State = ivi_rotary_left;
        break;
      case ivi_rotary2_r:
        ReRender = 1;
        Fields[ivi_rotary2].State = ivi_rotary_right;
        break;
      case ivi_rotary3_dn:
        ReRender = 1;
        Fields[ivi_rotary3].State = ivi_rotary_left;
        break;
      case ivi_rotary3_up:
        ReRender = 1;
        Fields[ivi_rotary3].State = ivi_rotary_right;
        break;
      case pcdp_rotary_rndz:
        ReRender = 1;
        Fields[pcdp_rotary].State = pcdp_rotary_0;
        break;
      case pcdp_rotary_td:
        ReRender = 1;
        Fields[pcdp_rotary].State = pcdp_rotary_1;
        break;
      case pcdp_rotary_pre_re_ent:
        ReRender = 1;
        Fields[pcdp_rotary].State = pcdp_rotary_2;
        break;
      case pcdp_rotary_pre_ln:
        ReRender = 1;
        Fields[pcdp_rotary].State = pcdp_rotary_5;
        break;
      case pcdp_rotary_asc:
        ReRender = 1;
        Fields[pcdp_rotary].State = pcdp_rotary_6;
        break;
      case pcdp_rotary_ctchup:
        ReRender = 1;
        Fields[pcdp_rotary].State = pcdp_rotary_7;
        break;
      case trs_et_rotary_0:
        ReRender = 1;
        Fields[trs_et_rotary].State = trs_et_rotary_middle;
        DEBUG_DSPN(4)
        ;
        break;
      case trs_et_rotary_incr_1:
        ReRender = 1;
        Fields[trs_et_rotary].State = trs_et_rotary_right1;
        DEBUG_DSPN(5)
        ;
        break;
      case trs_et_rotary_incr_2:
        ReRender = 1;
        Fields[trs_et_rotary].State = trs_et_rotary_right2;
        DEBUG_DSPN(6)
        ;
        break;
      case trs_et_rotary_incr_3:
        ReRender = 1;
        Fields[trs_et_rotary].State = trs_et_rotary_right3;
        DEBUG_DSPN(7)
        ;
        break;
      case trs_et_rotary_decr_1:
        ReRender = 1;
        Fields[trs_et_rotary].State = trs_et_rotary_left1;
        DEBUG_DSPN(3)
        ;
        break;
      case trs_et_rotary_decr_2:
        ReRender = 1;
        Fields[trs_et_rotary].State = trs_et_rotary_left2;
        DEBUG_DSPN(2)
        ;
        break;
      case trs_et_rotary_decr_3:
        ReRender = 1;
        Fields[trs_et_rotary].State = trs_et_rotary_left3;
        DEBUG_DSPN(1)
        ;
        break;
      case trs_metdc_rotary_0:
        ReRender = 1;
        Fields[trs_metdc_rotary].State = trs_metdc_rotary_middle;
        break;
      case trs_metdc_rotary_incr_1:
        ReRender = 1;
        Fields[trs_metdc_rotary].State = trs_metdc_rotary_right1;
        break;
      case trs_metdc_rotary_incr_2:
        ReRender = 1;
        Fields[trs_metdc_rotary].State = trs_metdc_rotary_right2;
        break;
      case trs_metdc_rotary_incr_3:
        ReRender = 1;
        Fields[trs_metdc_rotary].State = trs_metdc_rotary_right3;
        break;
      case trs_metdc_rotary_decr_1:
        ReRender = 1;
        Fields[trs_metdc_rotary].State = trs_metdc_rotary_left1;
        break;
      case trs_metdc_rotary_decr_2:
        ReRender = 1;
        Fields[trs_metdc_rotary].State = trs_metdc_rotary_left2;
        break;
      case trs_metdc_rotary_decr_3:
        ReRender = 1;
        Fields[trs_metdc_rotary].State = trs_metdc_rotary_left3;
        break;
        };
      if (ReRender)
        {
          wxPaintDC dc(this);
          render(dc);
        }
    }
}

void
wxImagePanel::ButtonIsPressed(enum GraphicIndex_t Index)
{
  int ScaledLeft, ScaledTop;

  ScaledLeft = (w * Fields[WidgetIndex].Left + BackgroundWidth / 2)
      / BackgroundWidth;
  ScaledTop = (h * Fields[WidgetIndex].Top + BackgroundHeight / 2)
      / BackgroundHeight;
  wxBitmap widget = wxBitmap(*Graphics[Index].ScaledImage);
  wxPaintDC dc(this);
  dc.DrawBitmap(widget, ScaledLeft, ScaledTop, false);
}

void
wxImagePanel::Rescale(wxImage *Unscaled, wxImage *Scaled)
{
  int ScaledWidgetWidth, ScaledWidgetHeight;
  ScaledWidgetWidth = (w * Unscaled->GetWidth() + BackgroundWidth / 2)
      / BackgroundWidth;
  ScaledWidgetHeight = (h * Unscaled->GetHeight() + BackgroundHeight / 2)
      / BackgroundHeight;
  *Scaled = Unscaled->Scale(ScaledWidgetWidth, ScaledWidgetHeight,
      wxIMAGE_QUALITY_HIGH);
}

void
wxImagePanel::BufferedComposite(wxMemoryDC *bdc, wxImage *Image, int x, int y)
{
  int ScaledLeft, ScaledTop;

  ScaledLeft = (w * x + BackgroundWidth / 2) / BackgroundWidth
      - Image->GetWidth() / 2;
  ScaledTop = (h * y + BackgroundHeight / 2) / BackgroundHeight
      - Image->GetHeight() / 2;
  wxBitmap widget = wxBitmap(*Image);
  wxPaintDC dc(this);
  bdc->DrawBitmap(widget, ScaledLeft, ScaledTop, false);
}

void
wxImagePanel::leftUp(wxMouseEvent& event)
{
  if (WidgetIndex >= 0)
    {
      // Take care of spring-loaded toggles and rotaries
      // here ... let them spring back when the mouse
      // releases.
      Fields[trs_et_toggle1].State = toggle_middle;
      Fields[trs_et_toggle2].State = toggle_middle;
      Fields[trs_metdc_toggle].State = toggle_middle;
      Fields[ivi_rotary1].State = ivi_rotary_middle;
      Fields[ivi_rotary2].State = ivi_rotary_middle;
      Fields[ivi_rotary3].State = ivi_rotary_middle;
      wxPaintDC dc(this);
      render(dc);
    }
}

void
wxImagePanel::rightClick(wxMouseEvent& event)
{
  wxMessageBox(wxT("Right-click"), wxT("FYI"), wxOK);
}

/*
 * Called by the system of by wxWidgets when the panel needs
 * to be redrawn. You can also trigger this call by
 * calling Refresh()/Update().
 */

void
wxImagePanel::paintEvent(wxPaintEvent & evt)
{
  // depending on your system you may need to look at double-buffered dcs
  wxPaintDC dc(this);
  render(dc);
}

/*
 * Alternatively, you can use a clientDC to paint on the panel
 * at any time. Using this generally does not free you from
 * catching paint events, since it is possible that e.g. the window
 * manager throws away your drawing when the window comes to the
 * background, and expects you will redraw it when the window comes
 * back (by sending a paint event).
 */
void
wxImagePanel::paintNow()
{
  // depending on your system you may need to look at double-buffered dcs
  wxClientDC dc(this);
  render(dc);
}

/*
 * Here we do the actual rendering. I put it in a separate
 * method so that it can work no matter what type of DC
 * (e.g. wxPaintDC or wxClientDC) is used.
 */
void
wxImagePanel::render(wxDC& dc)
{
  int neww, newh;

  dc.GetSize(&neww, &newh);
  // Adjust aspect ratio.
  if (BackgroundWidth * newh > neww * BackgroundHeight)
    newh = (neww * BackgroundHeight) / BackgroundWidth;
  else
    neww = (newh * BackgroundWidth) / BackgroundHeight;

  if (neww != w || newh != h)
    {
      //static int Count = 0;
      //printf ("Rescale %d: %d %d -> %d %d\n", ++Count, w, h, neww, newh);
      w = neww;
      h = newh;
      resized = wxBitmap(image.Scale(neww, newh, wxIMAGE_QUALITY_HIGH));
      int i;
      for (i = 1; i < NumGraphics; i++) // Skip initial dummy entry.
        Rescale(Graphics[i].UnscaledImage, Graphics[i].ScaledImage);
      for (i = 0; i < MAX_CLOCK_ANGLES; i++)
        {
          Rescale(HandsHours[i].UnscaledImage, HandsHours[i].ScaledImage);
          Rescale(HandsMinutes[i].UnscaledImage, HandsMinutes[i].ScaledImage);
          Rescale(HandsSeconds[i].UnscaledImage, HandsSeconds[i].ScaledImage);
        }
    }
  wxMemoryDC wdc(resized);
  wxBitmap Buffer(resized.GetWidth(), resized.GetHeight());
  wxMemoryDC bdc(Buffer);
  bdc.DrawBitmap(resized, 0, 0, false);
  int i;
  for (i = 0; i < NumFields; i++)
    if (Fields[i].Type == FT_OUT && Fields[i].State != gi_none)
      BufferedComposite(&bdc, Graphics[Fields[i].State].ScaledImage,
          Fields[i].x, Fields[i].y);
  // Do the accutron clock hands.
  time_t t;
  struct tm *tm_struct;
  time(&t);
  tm_struct = gmtime(&t);
  printf("%d %d %d %d %d %p %p %p\n", Fields[trs_ac_hands].x,
      Fields[trs_ac_hands].y, tm_struct->tm_hour * 5, tm_struct->tm_min * 2,
      tm_struct->tm_sec * 2, HandsHours[tm_struct->tm_hour * 5].ScaledImage,
      HandsMinutes[tm_struct->tm_min * 2].ScaledImage,
      HandsSeconds[tm_struct->tm_sec * 2].ScaledImage);
  BufferedComposite(&bdc, HandsHours[tm_struct->tm_hour * 5].ScaledImage,
      Fields[trs_ac_hands].x, Fields[trs_ac_hands].y);
  BufferedComposite(&bdc, HandsMinutes[tm_struct->tm_min * 2].ScaledImage,
      Fields[trs_ac_hands].x, Fields[trs_ac_hands].y);
  BufferedComposite(&bdc, HandsSeconds[tm_struct->tm_sec * 2].ScaledImage,
      Fields[trs_ac_hands].x, Fields[trs_ac_hands].y);
  // Now actually write the buffer to the screen.
  dc.DrawBitmap(Buffer, 0, 0, false);
}

/*
 * Here we call refresh to tell the panel to draw itself again.
 * So when the user resizes the image panel the image should be resized too.
 */
void
wxImagePanel::OnSize(wxSizeEvent& event)
{
  Refresh();
  //skip the event.
  event.Skip();
}

// ----------------------------------------

class MyApp : public wxApp
{

  wxFrame *frame;
  wxImagePanel * drawPane;
public:
  bool
  OnInit()
  {
    // make sure to call this first
    wxInitAllImageHandlers();

    // Read in the file that lists all of the positions of the input-
    // and output fields in the background PNG.
      {
        FILE *fp;
        char s[129], Name[MAX_NAME_SIZE];
        int i1, i2, i3, i4;

        BackgroundWidth = 0;
        BackgroundHeight = 0;

        fp = fopen("yaPanel.coordinates", "rb");
        if (fp == NULL)
          {
            wxMessageBox(wxT("Could not open yaPanel.coordinates"), wxT(
                "Fatal error"), wxOK | wxICON_ERROR);
            return (false);
          }
        while (NULL != fgets(s, sizeof(s), fp))
          {
            if (5 == sscanf(s, "%" NAME_FIELD_WIDTH "s%d%d%d%d", Name, &i1,
                &i2, &i3, &i4))
              {
                int i;
                for (i = 0; i < NumFields; i++)
                  if (!strcmp(Fields[i].Name, Name))
                    break;
                if (i < NumFields)
                  {
                    if (i2 < 0)
                      i2 += BackgroundHeight - 1;
                    if (i4 < 0)
                      i4 += BackgroundHeight - 1;
                    if (i1 > i3)
                      {
                        int i;
                        i = i1;
                        i1 = i3;
                        i3 = i1;
                      }
                    if (i2 > i4)
                      {
                        int i;
                        i = i2;
                        i2 = i4;
                        i4 = i;
                      }
                    strcpy(Fields[i].Name, Name);
                    Fields[i].Type = FT_IN;
                    Fields[i].Left = i1;
                    Fields[i].Top = i2;
                    Fields[i].Right = i3;
                    Fields[i].Bottom = i4;
                  }
              }
            else if (3 == sscanf(s, "%" NAME_FIELD_WIDTH "s%d%d", Name, &i1,
                &i2))
              {
                if (!strcmp(Name, "size"))
                  {
                    BackgroundWidth = i1;
                    BackgroundHeight = i2;
                  }
                else
                  {
                    int i;
                    for (i = 0; i < NumFields; i++)
                      if (!strcmp(Fields[i].Name, Name))
                        break;
                    if (i < NumFields)
                      {
                        if (i2 < 0)
                          i2 += BackgroundHeight - 1;
                        strcpy(Fields[i].Name, Name);
                        Fields[i].Type = FT_OUT;
                        Fields[i].x = i1;
                        Fields[i].y = i2;
                      }
                  }
              }
          }
      }
    if (BackgroundWidth == 0 || BackgroundHeight == 0)
      {
        wxMessageBox(wxT("Size-fields not found in yaPanel.coordinates"), wxT(
            "Fatal error"), wxOK | wxICON_ERROR);
        return (false);
      }

    //#define FLEXGRID
#ifndef FLEXGRID
    wxBoxSizer* sizer = new wxBoxSizer(wxHORIZONTAL);
#else
    wxFlexGridSizer* sizer = new wxFlexGridSizer (3, 3, 0, 0);
    sizer->AddGrowableRow (1, 1);
    sizer->AddGrowableCol (1, 1);
#endif
    frame = new wxFrame(NULL, wxID_ANY, wxT("Test yaPanel"), wxPoint(50, 50),
        wxSize(BackgroundWidth, BackgroundHeight));

    // then simply create like this
    drawPane = new wxImagePanel(frame, wxT("yaPanel.png"), wxBITMAP_TYPE_PNG);
#ifndef FLEXGRID
    sizer->Add(drawPane, 100, wxEXPAND);
#else
    sizer->AddStretchSpacer();
    sizer->AddStretchSpacer();
    sizer->AddStretchSpacer();
    sizer->AddStretchSpacer();
    sizer->Add(drawPane, 100, wxSHAPED);
    sizer->AddStretchSpacer();
    sizer->AddStretchSpacer();
    sizer->AddStretchSpacer();
    sizer->AddStretchSpacer();
#endif

    frame->SetSizer(sizer);
    drawPane->CaptureMouse();

    frame->Show();
    return true;
  }

};

IMPLEMENT_APP( MyApp)
