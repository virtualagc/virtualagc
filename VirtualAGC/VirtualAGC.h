/*
 * Copyright 2009,2016,2017,2019,2020,2022 Ronald S. Burkey <info@sandroid.org>
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
 * Filename:	VirtualAGC.h
 * Purpose:	This is a class-definition header file for VirtualAGC.cpp.
 * 		The purpose of VirtualAGC is to provide a cross-platform
 *		GUI front-end that can be used to start up a Virtual AGC
 *		simulation (yaAGC, yaDSKY, yaAGS, etc.) in a convenient
 *		way.
 * Mods:	2009-03-02 RSB	Began.
 * 		2009-03-11 RSB	Added yaTelemetry.
 *		2009-03-15 RSB	Added missing IDs for some simulation-type
 *				radio buttons.  Added the source-view
 *				buttons.
 *		2009-03-17 RSB	Added the script info to the Simulation
 *				run window.
 *		2009-03-23 RSB	Added digital-upload stuff.
 *		2009-04-21 RSB	Main screen rework/resize.
 *		2009-07-24 RSB	Replaced Colossus249 references with
 *				Apollo8Cm references, since I now think
 *				that 249 was for Apollo 9 and 237 was
 *				for Apollo 8.
 *		2016-08-28 RSB  Added Apollo 3-6 buttons.
 *		2016-11-07 RSB  Added Retread44, Aurora12, Sunburst39, and
 *		                Zerlina buttons.
 *	        2016-11-08 RSB  Added DSKY "nav" style.
 *	        2016-11-10 RSB  Refactored in terms of being a lot simpler to
 *	                        add or edit mission types.  Removed all of the
 *	                        lingering comments inserted by wxGlade.
 *	        2017-03-24 RSB  Added a SUPERJOB mission type.
 *          	2017-05-30 RSB	Changed bogus references to Sunburst 39 to Sunburst 37.
 *          	2019-06-17 RSB	Added Retread50 button.
 *          	2019-07-23 RSB	Added a SundialE button.
 *          	2019-07-27 RSB  Added LUM69R2 button.
 *          	2019-07-31 RSB	Added Comanche 51 button.  I seem to have forgotten
 *          			to note adding Luminary 97, 98, and 130 buttons a
 *          			could of days back.
 *          	2019-08-16 RSB	Added Artemis 71.
 *          	2019-09-22 RSB  Added Luminary 163 and 173
 *          	2020-12-06 RSB  Added Comanche 44 and 45, though 45 isn't available yet.
 *          	2021-08-24 RSB  Added Luminary 96, removed 99R2
 *          	2022-07-18 RSB  Nobody has ever complained about it, but
 *          	                I've become so irked by the "Simulation Status"
 *          	                window covering up all the other stuff at the
 *          	                center of the screen that I've moved it to
 *          	                the upper left.
 *              2022-10-28 RSB  Added LM131R1, SUNRISE45, and SUNRISE69.
 *              2022-11-17 RSB  Added Aurora 88.
 *              2024-05-21 RSB  Added Comanche 72.
 *              2025-01-11 RSB  Added a Tic-tac-toe "mission".
 *
 * This file was originally generated using the wxGlade RAD program.
 * However, it is now maintained entirely manually, and any ability to
 * manage it with wxGlade has vanished.
 *
 * Adding/editing mission types requires the following steps:
 *
 *   1. In this file, VirtualAGC.h, add an ID_xxxx enum for it,
 *      >=ID_FIRSTMISSION and <ID_AGCCUSTOMBUTTON.
 *   2. In the file VirtualAGC.cpp, add an entry for it in the
 *      missionConstants[] array.  The entries are in the same order as
 *      the ID_xxxx enums, with missionConstants[0] corresponding to
 *      ID_FIRSTMISSION.
 *   3. In VirtualAGC.cpp, add an entry in the VirtualAGC EVENT_TABLE of the
 *      form "EVT_RADIOBUTTON(ID_xxxx, VirtualAGC::ConsistencyEvent)",
 *      where ID_xxxx is the only value you have to change.
 *   4. For most missions, that's all you have to do.  However, a handful
 *      of missions require addition of extra code, using the
 *      missionRadioButtons[] and missionConstants[] array entries.  You
 *      can do a search for ID_LUMINARY131BUTTON to see what some of those
 *      kinds of things are.  Most functionality, though, is entirely
 *      customized by the entries placed in the missionConstants[] array in
 *      step 2 above.
 */

#include <wx/wx.h>
#include <wx/image.h>
#include <wx/statline.h>

#ifndef VIRTUALAGC_H
#define VIRTUALAGC_H

// Constants for identifying widgets.  Any wxWidget which has associated
// events should have an ID here.  The numerical values are arbitrary as
// far as wxWidgets is concerned, but the program itself uses certain
// interrelationships ... specifically that all "mission" (AGC software
// program/version) types obey ID_FIRSTMISSION <= ID < ID_AGCCUSTOMBUTTON.
enum
{
  ID_AGCFILENAMELABEL = 0,
  ID_AGCCUSTOMFILENAME,
  ID_AGCFILENAMEBROWSE,
  ID_AEAFILENAMELABEL,
  ID_AEACUSTOMFILENAME,
  ID_AEAFILENAMEBROWSE,
  ID_AGCSOFTWAREDROPDOWNLIST,
  ID_DEVICEAGCCHECKBOX,
  ID_DEVICEDSKYCHECKBOX,
  ID_DEVICEACACHECKBOX,
  ID_DEVICETELEMETRYCHECKBOX,
  ID_DEVICEAEACHECKBOX,
  ID_DEVICEDEDACHECKBOX,
  ID_DEVICECPUMONCHECKBOX,
  ID_DEVICEIMUCHECKBOX,
  ID_DEVICEDISCOUTCHECKBOX,
  ID_DEVICECREWINCHECKBOX,
  ID_DEVICESYSINCHECKBOX,
  ID_DEVICEPROPULSIONCHECKBOX,
  ID_NOVICEBUTTON,
  ID_EXPERTBUTTON,
  ID_RUNBUTTON,
  ID_DEFAULTSBUTTON,
  ID_EXITBUTTON,
  ID_AGCSOURCEBUTTON,
  ID_AEASOURCEBUTTON,
  ID_JOYSTICKCONFIGURE,
  ID_AGCSIMTYPEBOX = 100,
  ID_FIRSTMISSION,
  ID_APOLLO1CMBUTTON = ID_FIRSTMISSION,
  ID_APOLLO3CMBUTTON,
  ID_APOLLO4CMBUTTON,
  ID_APOLLO5LMBUTTON,
  ID_APOLLO6CMBUTTON,
  ID_SUNDIALECMBUTTON,
  ID_APOLLO7CMBUTTON,
  ID_APOLLO8CMBUTTON,
  ID_APOLLO9CMBUTTON,
  ID_APOLLO9LMBUTTON,
  ID_COMANCHE44BUTTON,
  ID_COMANCHE45BUTTON,
  ID_APOLLO10CMBUTTON,
  ID_LUM69BUTTON,
  ID_APOLLO10LMBUTTON,
  ID_COMANCHE51BUTTON,
  ID_COMANCHE55BUTTON,
  ID_LUMINARY96BUTTON,
  ID_LUMINARY97BUTTON,
  ID_LUMINARY98BUTTON,
  ID_LMY99R0BUTTON,
  ID_LUMINARY99BUTTON,
  // ID_LUM99R2BUTTON,
  ID_APOLLO12CMBUTTON,
  ID_APOLLO12LMBUTTON,
  ID_COMANCHE72BUTTON,
  ID_APOLLO13CMBUTTON,
  ID_LUMINARY130BUTTON,
  ID_LUMINARY131BUTTON,
  ID_LM131R1BUTTON,
  ID_APOLLO14CMBUTTON,
  ID_LUMINARY163BUTTON,
  ID_LUMINARY173BUTTON,
  ID_APOLLO14LMBUTTON,
  ID_ARTEMIS71BUTTON,
  ID_ARTEMIS72BUTTON,
  ID_APOLLO15LMBUTTON,
  ID_SKYLABCMBUTTON,
  ID_SOYUZCMBUTTON,
  ID_VALIDATIONBUTTON,
  ID_SUNRISE45BUTTON,
  ID_SUNRISE69BUTTON,
  ID_RETREAD44BUTTON,
  ID_RETREAD50BUTTON,
  ID_AURORA88BUTTON,
  ID_AURORA12BUTTON,
  ID_BOREALISBUTTON,
  ID_SUNBURST37BUTTON,
  ID_ZERLINA56BUTTON,
  ID_SUPERJOBBUTTON,
  ID_TICTACTOEBUTTON,
  ID_AGCCUSTOMBUTTON,
  ID_AEASIMTYPEBOX = 200,
  ID_FLIGHTPROGRAM4BUTTON,
  ID_FLIGHTPROGRAM5BUTTON,
  ID_FLIGHTPROGRAM6BUTTON,
  ID_FLIGHTPROGRAM7BUTTON,
  ID_FLIGHTPROGRAM8BUTTON,
  ID_AEACUSTOMBUTTON,
  ID_STARTUPOPTIONSBOX = 300,
  ID_STARTUPWIPEBUTTON,
  ID_STARTUPPRESERVEBUTTON,
  ID_STARTUPRESUMEBUTTON,
  ID_CUSTOMRESUMEBUTTON,
  ID_COREBROWSE,
  ID_CORESAVEBUTTON,
  ID_DSKYTYPEBOX = 400,
  ID_DSKYFULLBUTTON,
  ID_DSKYHALFBUTTON,
  ID_DSKYLITEBUTTON,
  ID_DSKYNAVBUTTON,
  ID_DSKYNAVHALFBUTTON,
  ID_DSKYAPOBUTTON,
  ID_DSKYAPOHALFBUTTON,
  ID_AGCDEBUGBOX = 500,
  ID_AGCDEBUGNORMALBUTTON,
  ID_AGCDEBUGMONITORBUTTON,
  ID_DEDATYPEBOX = 600,
  ID_DEDAFULLBUTTON,
  ID_DEDAHALFBUTTON,
  ID_AEADEBUGBOX = 700,
  ID_AEADEBUGNORMALBUTTON,
  ID_AEADEBUGMONITORBUTTON,
  ID_SIMULATIONLABEL = 800,
  ID_MORE,
  ID_LESS,
  ID_UPLOAD
};

#define DISABLED 0
#define ENABLED 1
#define CM 0
#define LM 1
#define BLOCK2 0
#define BLOCK1 1
#define NO_PERIPHERALS 0
#define PERIPHERALS 1
#define TELEMETRY_PERIPHERALS 2
// Configuration data for a single "mission".  See missionConstants[] in
// VirtualAGC.cpp.
typedef struct
{
  const char name[64]; // Short descriptive name for UI display purposes
  const char html[64]; // Fragment of pathname to top-level HTML file
  const char tooltip[256]; // Longer description of the mission
  int enabled; // Either DISABLED (grayed-out) or ENABLED in the UI.
  int lm; // Either LM or CM.
  int Block1; // Either BLOCK2 or BLOCK1.
  // For `noPeripherals`:
  // 	NO_PERIPHERALS = Only DSKY allowed.
  // 	TELEMETRY_PERIPHERAL = Only DSKY and telemetry allowed.
  // 	PERIPHERALS = All peripherals allowed.
  int noPeripherals;
  const char basename[32]; // Fragment of name for locating the rope file.
  const char dsky[16]; // DSKY config file, usually LM.ini or CM.ini. Ignored for Block 1.
} missionAlloc_t;

class TimerClass : public wxTimer
{
public:
  virtual ~TimerClass() {};
  int IoErrorCount;
  int Portnum;
  int KeycodeIndex;

private:
  virtual void
  Notify();
};

// This class is used only whilst running a simulation.
class Simulation : public wxFrame
{
public:

  virtual ~Simulation() {};
  Simulation(wxWindow* parent, int id, const wxString& title,
      const wxPoint& pos = wxPoint(0,0),
      const wxSize& size = wxDefaultSize, long style = wxDEFAULT_FRAME_STYLE | wxRESIZE_BORDER);
  void
  WriteSimulationLabel(wxString Label);
  unsigned char Keycodes[8192];
  int NumKeycodes;
  bool MoreEnabled, LessEnabled, DetailShown;
  enum
  {
    UT_UNKNOWN, UT_CM, UT_LM, UT_AEA
  } UnitType;

private:
  void
  set_properties();
  void
  do_layout();

  void
  Upload(wxString &Filename);
  TimerClass *Timer;

public:
  wxStaticBox* sizer_32_staticbox;
  wxStaticBox* sizer_33_staticbox;
  wxStaticBitmap* PatchBitmap;
  wxStaticText* SimulationLabel;
  wxButton* MoreButton;
  wxButton* LessButton;
  wxButton* UploadButton;
  wxTextCtrl* UplinkText;
  wxPanel* UplinkPanel;
  wxTextCtrl* ScriptText;
  wxPanel* ScriptPanel;
  wxPanel* DetailPanel;

  DECLARE_EVENT_TABLE()

public:
  virtual void
  MoreEvent(wxCommandEvent &event);
  virtual void
  LessEvent(wxCommandEvent &event);
  virtual void
  UploadEvent(wxCommandEvent &event);
};

class VirtualAGC : public wxFrame
{
public:

  VirtualAGC(wxWindow* parent, int id, const wxString& title,
      const wxPoint& pos = wxDefaultPosition,
      const wxSize& size = wxDefaultSize, long style = wxDEFAULT_FRAME_STYLE);
  virtual ~VirtualAGC() {};

  // For keeping track of a running simulation.
  Simulation *SimulationWindow;
  void
  EnableRunButton(void);
  long SimulationProcessID;
  void
  SetFontSizes(void);
  int Points, StartingPoints;
  bool ReallySmall;
  bool DropDown;
  wxString ResourceDirectory;		// Where the images, cfg files, etc. are stored.
  bool IsLM;
  bool CmSim, LmSim, AeaSim;
  bool FunkyYaACA;
  bool block1;
  wxRadioButton* missionRadioButtons[ID_AGCCUSTOMBUTTON - ID_FIRSTMISSION];

private:
  void
  set_properties();
  void
  do_layout();

  bool
  FormLmsIni(void);
  bool
  FormTiling(void);
  bool
  FormCommands(void);
  bool
  FormScript(void);
  wxString AgcDirectory;
  wxString AeaDirectory;
  wxString ExecutableDirectory;	// Where the executables are stored.
  wxString RunDirectory;		// A directory in which to run the simulation.
  wxString PathDelimiter;
  wxString HomeDirectory;
  // Command lines for other executables.
  wxString yaAGC, yaDSKY, yaACA, yaAGS, yaDEDA, LM_Simulator, yaTelemetry;
  wxArrayString SoftwareVersionNames;

  void
  EnableLM(bool YesNo);		// Enables/disables LM-specific settings
  void
  EnableAEA(bool YesNo);	// Enables/disables AEA-specific settings
  void
  EnableDEDA(bool YesNo);	// Enables/disables DEDA-specific settings
  void
  EnableCustomAGC(bool YesNo);	// Enables/disables custom AGC software settings
  void
  EnableCustomAEA(bool YesNo);	// Enables/disables custom AGS software settings
  void
  EnableCpumon(bool YesNo);	// Enables/disables LM-Simulator settings.
  void
  EnforceConsistency(void);	// Enable/disable all controls to be consistent.
  void
  SetDefaultConfiguration(void);
  void
  ReadConfigurationFile(void);
  void
  WriteConfigurationFile(void);
  void
  ConvertDropDown(void);
  void
  ConvertRadio(void);

protected:
  wxStaticBox* sizer_20_staticbox;
  wxStaticBox* sizer_38_staticbox;
  wxStaticBox* sizer_22_staticbox;
  wxStaticBox* sizer_18_staticbox;
  wxStaticBox* sizer_1_copy_staticbox;
  wxStaticBox* sizer_19_staticbox;
  wxStaticBitmap* Patch1Bitmap;
  wxStaticBitmap* Patch7Bitmap;
  wxStaticBitmap* Patch8Bitmap;
  wxStaticBitmap* Patch9Bitmap;
  wxStaticBitmap* Patch10Bitmap;
  wxStaticBitmap* Patch11Bitmap;
  wxStaticBitmap* PatchBitmap;
  wxStaticBitmap* Patch12Bitmap;
  wxStaticBitmap* Patch13Bitmap;
  wxStaticBitmap* Patch14Bitmap;
  wxStaticBitmap* Patch15Bitmap;
  wxStaticBitmap* Patch16Bitmap;
  wxStaticBitmap* Patch17Bitmap;
  wxStaticLine* TopLine;
  wxStaticText* SimTypeLabel;
  wxStaticText* SimTypeLabel2;
  wxRadioButton* AgcCustomButton;
  wxTextCtrl* AgcCustomFilename;
  wxButton* AgcFilenameBrowse;
  wxStaticLine* static_line_2;
  wxStaticText* DeviceListLabel;
  wxChoice *DeviceAGCversionDropDownList;
  wxCheckBox* DeviceAgcCheckbox;
  wxCheckBox* DeviceDskyCheckbox;
  wxCheckBox* DeviceAcaCheckbox;
  wxButton* JoystickConfigure;
  wxCheckBox* DeviceTelemetryCheckbox;
  wxCheckBox* DeviceAeaCheckbox;
  wxCheckBox* DeviceDedaCheckbox;
  wxCheckBox* DeviceCpumonCheckbox;
  wxStaticLine* static_line_4;
  wxCheckBox* DeviceImuCheckbox;
  wxCheckBox* DeviceDiscoutCheckbox;
  wxCheckBox* DeviceCrewinCheckbox;
  wxCheckBox* DeviceSysinCheckbox;
  wxCheckBox* DevicePropulsionCheckbox;
  wxButton* NoviceButton;
  wxButton* ExpertButton;
  wxStaticLine* static_line_3;
  wxStaticLine* static_line_5;
  wxButton* AgcSourceButton;
  wxButton* AeaSourceButton;
  wxStaticText* OptionList;
  wxRadioButton* StartupWipeButton;
  wxRadioButton* StartupPreserveButton;
  wxRadioButton* StartupResumeButton;
  wxRadioButton* CustomResumeButton;
  wxTextCtrl* CoreFilename;
  wxButton* CoreBrowse;
  wxButton* CoreSaveButton;
  wxStaticText* DskyLabel;
  wxRadioButton* DskyFullButton;
  wxRadioButton* DskyHalfButton;
  wxRadioButton* DskyLiteButton;
  wxRadioButton* DskyNavButton;
  wxRadioButton* DskyNavHalfButton;
  wxRadioButton* DskyApoButton;
  wxRadioButton* DskyApoHalfButton;
  wxStaticText* DownlinkLabel;
  wxRadioButton* TelemetryResizable;
  wxRadioButton* TelemetryRetro;
  wxStaticText* DedaLabel;
  wxRadioButton* DedaFullButton;
  wxRadioButton* DedaHalfButton;
  wxStaticText* AgcDebugLabel;
  wxRadioButton* AgcDebugNormalButton;
  wxRadioButton* AgcDebugMonitorButton;
  wxStaticText* AeaDebugLabel;
  wxRadioButton* AeaDebugNormalButton;
  wxRadioButton* AeaDebugMonitorButton;
  wxRadioButton* FlightProgram4Button;
  wxRadioButton* FlightProgram5Button;
  wxRadioButton* FlightProgram6Button;
  wxRadioButton* FlightProgram7Button;
  wxRadioButton* FlightProgram8Button;
  wxRadioButton* AeaCustomButton;
  wxTextCtrl* AeaCustomFilename;
  wxButton* AeaFilenameBrowse;
  wxStaticLine* static_line_1;
  wxButton* RunButton;
  wxButton* DefaultsButton;
  wxBoxSizer* optionsBox;
  wxStaticBoxSizer* agcStartupBox;
  wxGridSizer* interfaceStylesBox;
  wxGridSizer* debuggerBox;

  DECLARE_EVENT_TABLE()

public:
  wxButton* ExitButton;

  virtual void
  ConsistencyEvent(wxCommandEvent &event);
  virtual void
  AgcFilenameBrowseEvent(wxCommandEvent &event);
  virtual void
  AeaFilenameBrowseEvent(wxCommandEvent &event);
  virtual void
  NoviceButtonEvent(wxCommandEvent &event);
  virtual void
  ExpertButtonEvent(wxCommandEvent &event);
  virtual void
  RunButtonEvent(wxCommandEvent &event);
  virtual void
  DefaultsButtonEvent(wxCommandEvent &event);
  virtual void
  ExitButtonEvent(wxCommandEvent &event);
  virtual void
  AgcSourceEvent(wxCommandEvent &event);
  virtual void
  AeaSourceEvent(wxCommandEvent &event);
  virtual void
  CoreBrowseEvent(wxCommandEvent &event);
  virtual void
  CoreSaveEvent(wxCommandEvent &event);
  virtual void
  JoystickConfigureClicked(wxCommandEvent &event);
};

#endif // VIRTUALAGC_H
