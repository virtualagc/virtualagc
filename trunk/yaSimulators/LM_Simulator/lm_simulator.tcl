# Copyright 2005-2007 Stephan Hotto <stephan.hotto@web.de>
#
# This file is part of yaAGC.
#
# yaAGC is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# yaAGC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with yaAGC; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

# ***********************************************************************************************
# **** Program:       LM Simulator                                                           ****
# **** Function:      Simulates different LM Systems                                         ****
# **** Language:      TCL/TK                                                                 ****
# **** Invoke:        wish lm_simulator                                                      ****
# ****                (As a pre-condition the TCL/TK package has to be installed)            ****
# **** Date/Location: 21.04.2007/Germany                                                     ****
# **** Version:       v1.0                                                                   ****
# **** Author:        Stephan Hotto                                                          ****
# ***********************************************************************************************

# --------------------------- Global Variables --------------------------------------------------
set tcl_precision                 17
set font0                         -adobe-courier-medium-r-normal--10-*-*-*-*-*-*-*
set font11                        -adobe-courier-medium-r-normal--11-*-*-*-*-*-*-*
set font11b                       -adobe-courier-bold-r-normal--11-*-*-*-*-*-*-*
set font1                         -adobe-courier-medium-r-normal--12-*-*-*-*-*-*-*
set font2                         -adobe-courier-medium-r-normal--12-*-*-*-*-*-*-*
set font3                         -adobe-courier-bold-b-normal--12-*-*-*-*-*-*-*
set font4                         -adobe-courier-bold-b-normal--24-*-*-*-*-*-*-*
set serverIP                      "localhost"
set serverSock                    19801
set Operating_System              "linux"
set FDAI_Update_Rate              10
set FDAI_Mode                     1
set sockChan                      ""
set JET_FLAG                      0
set log_out_flag                  0
set log_in_flag                   0
set colb                          "gray90"
set colf                          "gray90"
set colb2                         "gray80"
set colb3                         "gray70"
set colb4                         "gray67"
set colact                        "white"
set calcol                        ""
set DSKY_MEM(10)                  ""
set DSKY_MEM(11)                  ""
set DSKY_MEM(13)                  ""
set bytesReceived                 0
set bytesSent                     0
set bytesSentCount                0
set simcount1                     0
set m2                            0
set m3                            0
set m4                            0
set m5                            0
set m6                            0
set m7                            0
set m8                            0
set flash_flag                    0
set s1p                           0
set s2p                           0
set s3p                           0
set s1m                           0
set s2m                           0
set s3m                           0
set R1                            ""
set R2                            ""
set R3                            ""
set R4                            ""
set pulse_count_x                 0
set pulse_count_y                 0
set pulse_count_z                 0
set RHC                           "NEUTRAL"
set THC                           "NEUTRAL"
set DAPMODE                       "OFF"
set R(0,0)                        0
set RA(0,0)                       0
set V(0,0)                        0
set widgtM(0)                     0
set offsetx                       150
set offsety                       180
set magnify                       100
set break_loop                    0
set MeterToFeet                   3.280948
set gimbalLock                    0
set path                          "./"
#set path                          "/LM_Simulator/"
set docpath                       "${path}doc/"
set modulpath                     "${path}modules/"
set config_file                   "lm_simulator.ini/"
set source0                       "${modulpath}AGC_DSKY.tcl"
set source1                       "${modulpath}AGC_Outputs.tcl"
set source2                       "${modulpath}AGC_System_Inputs.tcl"
set source3                       "${modulpath}AGC_Crew_Inputs.tcl"
set source4                       "${modulpath}AGC_IMU.tcl"
set source5                       "${modulpath}AGC_Simulation_Monitor_Control.tcl"

# ---------------- Unprogrammed Sequences ----------------------------
# ---- IN ----
set unpSeq(PINC)                  000000000000000
set unpSeq(MINC)                  000000000000010
set unpSeq(DINC)                  000000000000100
# ---- 400cps ----
set unpSeq(PCDU)                  000000000000001
set unpSeq(MCDU)                  000000000000011
# ---- 6400cps ----
set unpSeq(PCDU_FAST)             000000000010001
set unpSeq(MCDU_FAST)             000000000010011

# ---- OUT ----
set unpSeq(000000000001101)       POUT
set unpSeq(000000000001110)       MOUT
set unpSeq(000000000001111)       ZOUT

# ---------------- IMU Simulation Initialization ---------------------
# ---- 39.55078125'' of arc ----
set ANGLE_INCR                    [expr 360.0 / 32768.0]
set CA_ANGLE                      0.043948
set FA_ANGLE                      [expr 0.617981/3600.0]
set PIPA_INCR                     0.0585
set NEEDLE_SCALE                  [expr 42.1875/384.0]
set IMUX_ANGLE                    0
set IMUY_ANGLE                    0
set IMUZ_ANGLE                    0
set PIMUX                         0
set PIMUY                         0
set PIMUZ                         0
set PIPAX_COUNT                   0
set PIPAY_COUNT                   0
set PIPAZ_COUNT                   0
set xVelocity                     0
set yVelocity                     0
set zVelocity                     0
set RHCRoll                       0
set RHCPitch                      0
set RHCYaw                        0

# ---------------- Constant ------------------------------------------
set PI                            [expr 4.0 * atan(1)]
set 2PI                           [expr 2.0 * $PI]
set PI4                           [expr $PI/4.0]
set RAD_TO_DEG                    [expr 180.0/$PI]
set DEG_TO_RAD                    [expr $PI/180.0]
set RAD_TO_DEG_PI4                [expr 180.0/$PI*$PI4]

# ---------------- Simulation Start Values (LM-7 Configuration) ----------------------
set Simulation_Timer_Init         [expr abs([clock clicks -milliseconds])]
set Simulation_Timer              0
set Delta_Time                    0
set Delta_Time2                   0
set Delta_Time3                   0
set LM_Weight_KG                  0
set LM_Weight_Ascent_KG           4670.0
set LM_Weight_Descent_KG          10694.0
# ---- Reaction Control System ----
set RCS_Propellant_Mass_KG        287.0
set RCS_Thrust_N                  445.0
set RCS_Specific_Impulse_MS       2840.0
# ---- Descent Engine ----
set Descent_Propellant_Mass_KG    8355.0
set Descent_Propulsion_Max_N      45040.0
set Descent_Propulsion_Min_N      4560.0
set Descent_Specific_Impulse_MS   3050.0
set Descent_Propulsion_N          0
set Descent_Fuel_Flow_SEC         0
set Descent_Thrust_Procent        0
set Descent_Acceleration          0
set DESCENT_ENGINE_FLAG           0
# ---- Ascent Engine ----
set Ascent_Propellant_Mass_KG     2353.0
set Ascent_Thrust_N               15600.0
set Ascent_Specific_Impulse_MS    3050.0
set Ascent_Fuel_Flow_SEC          0
set Ascent_Acceleration           0
set ASCENT_ENGINE_FLAG            0
set ASCENT_SEPARATION             0
# ----
set Omega_Roll                    0
set Omega_Pitch                   0
set Omega_Yaw                     0
set Alpha_Yaw                     0
set Alpha_Pitch                   0
set Alpha_Roll                    0
set error_x                       0
set error_y                       0
set error_z                       0
# ---- Parameter to calculate Moment of Inertia ----
set LM_CONFIG                     "DESCENT"
# ---- LM Ascent Configuration ----
set a(ASCENT,YAW)                 0.0065443852
set b(ASCENT,YAW)                 0.000032
set c(ASCENT,YAW)                -0.006923
set a(ASCENT,PITCH)               0.0035784354
set b(ASCENT,PITCH)               0.162862
set c(ASCENT,PITCH)               0.002588
set a(ASCENT,ROLL)                0.0056946631
set b(ASCENT,ROLL)                0.009312
set c(ASCENT,ROLL)               -0.023608
# ---- LM Descent Configuration ----
set a(DESCENT,YAW)                0.0059347674
set b(DESCENT,YAW)                0.002989
set c(DESCENT,YAW)                0.008721
set a(DESCENT,PITCH)              0.0014979264
set b(DESCENT,PITCH)              0.018791
set c(DESCENT,PITCH)             -0.068163
set a(DESCENT,ROLL)               0.0010451889
set b(DESCENT,ROLL)               0.021345
set c(DESCENT,ROLL)              -0.066027
# ---- Set RCS Thruster to 0 ----
set Q4U 0; set Q4D 0; set Q3U 0; set Q3D 0
set Q2U 0; set Q2D 0; set Q1U 0; set Q1D 0
set Q3A 0; set Q4F 0; set Q1F 0; set Q2A 0
set Q2L 0; set Q3R 0; set Q4R 0; set Q1L 0


# **********************************************************************************************
# **** Function: Build the User Interface                                                   ****
# **********************************************************************************************
proc create_gui {} {
 global font0 font11 font1 font2 font3 log_in_flag log_out_flag cdata wdata bmask colb colf
 global bytesReceived bytesSent Operating_System

 wm title    . "LM Simulator v1.0 by Stephan Hotto"
 wm geometry . +0+0
 if {$Operating_System == "linux"} {
   wm geometry . 450x430; wm minsize  . 450 430
 } else {
   wm geometry . 450x470; wm minsize  . 450 470
 }
 wm iconname . "LM Simulator"
 
 . configure -background $colb

 create_menu

 frame .fp1 -bg $colb; frame .fp2 -bg $colb

 frame .fm1 -bg $colb; frame .fm2 -bg $colb; frame .fm3 -bg $colb

 frame .f0 -bg $colb; frame .f01 -bg $colb; frame .f1 -bg $colb; frame .f2 -bg $colb
 frame .f3 -bg $colb; frame .f4 -bg $colb; frame .f5 -bg $colb; frame .f6 -bg $colb
 frame .f7 -bg $colb; frame .f8 -bg $colb; frame .f81 -bg $colb; frame .f9 -bg $colb; 
 frame .f10 -bg $colb; frame .f101 -bg $colb; frame .f11 -bg $colb

 frame .f0r -bg $colb; frame .f01r -bg $colb; frame .f1r -bg $colb; frame .f2r -bg $colb
 frame .f3r -bg $colb; frame .f4r -bg $colb; frame .f5r -bg $colb; frame .f6r -bg $colb
 frame .f7r -bg $colb; frame .f8r -bg $colb; frame .f81r -bg $colb; frame .f9r -bg $colb
 frame .f10r -bg $colb; frame .f101r -bg $colb

 pack .fp1 .fp2 -side top -anchor w -pady 1 -padx 2

 pack .fm1 .fm2 -in .fp1 -side left -anchor n -pady 1 -padx 10
 pack .fm3 -in .fp2 -side top -anchor w -pady 0 -padx 1

 pack .f0 .f01 .f1 .f2 .f3 .f4 .f5 .f6 .f7 .f8 .f81 .f9 .f10 -in .fm1 -side top -anchor w -pady 1 -padx 1
 pack .f0r .f01r .f3r .f4r .f5r .f6r .f7r .f8r .f81r .f9r .f10r .f101r -in .fm2 -side top -anchor w -pady 1 -padx 1
 pack .f101 .f11 -in .fm3 -side top -anchor w -pady 2 -padx 2

 # ------------------------------- Output --------------------------------------
 label .l0 -text "    Output Channels" -font ${font3} -bg $colb
 pack .l0 -side left -in .f0
 # label .l01 -text "    MSB <-----> LSB" -font ${font1} -bg $colb
 # pack .l01 -side left -in .f01

 label .l1 -text " 5:" -font ${font1} -bg $colb
 entry .e1 -width 15 -relief groove -bd 2 -textvariable cdata(5) -font ${font1} -bg $colb
 pack .l1 .e1 -side left -in .f1

 label .l2 -text " 6:" -font ${font1} -bg $colb
 entry .e2 -width 15 -relief groove -bd 2 -textvariable cdata(6) -font ${font1} -bg $colb
 pack .l2 .e2 -side left -in .f2

 label .l3 -text " 7:" -font ${font1} -bg $colb
 entry .e3 -width 15 -relief groove -bd 2 -textvariable cdata(7) -font ${font1} -bg $colb
 pack .l3 .e3 -side left -in .f3

 label .l4 -text "10:" -font ${font1} -bg $colb
 entry .e4 -width 15 -relief groove -bd 2 -textvariable cdata(10) -font ${font1} -bg $colb
 pack .l4 .e4 -side left -in .f4

 label .l5 -text "11:" -font ${font1} -bg $colb
 entry .e5 -width 15 -relief groove -bd 2 -textvariable cdata(11) -font ${font1} -bg $colb
 pack .l5 .e5 -side left -in .f5 

 label .l6 -text "12:" -font ${font1} -bg $colb
 entry .e6 -width 15 -relief groove -bd 2 -textvariable cdata(12) -font ${font1} -bg $colb
 pack .l6 .e6 -side left -in .f6

 label .l7 -text "13:" -font ${font1} -bg $colb
 entry .e7 -width 15 -relief groove -bd 2 -textvariable cdata(13) -font ${font1} -bg $colb
 pack .l7 .e7 -side left -in .f7

 label .l8 -text "14:" -font ${font1} -bg $colb
 entry .e8 -width 15 -relief groove -bd 2 -textvariable cdata(14) -font ${font1} -bg $colb
 pack .l8 .e8 -side left -in .f8

 label .l81 -text "33:" -font ${font1} -bg $colb
 entry .e81 -width 15 -relief groove -bd 2 -textvariable cdata(33) -font ${font1} -bg $colb
 pack .l81 .e81 -side left -in .f81

 label .l9 -text "34:" -font ${font1} -bg $colb
 entry .e9 -width 15 -relief groove -bd 2 -textvariable cdata(34) -font ${font1} -bg $colb
 pack .l9 .e9 -side left -in .f9

 label .l10 -text "35:" -font ${font1} -bg $colb
 entry .e10 -width 15 -relief groove -bd 2 -textvariable cdata(35) -font ${font1} -bg $colb
 pack .l10 .e10 -side left -in .f10

 text .text -relief sunken -bd 2 -yscrollcommand ".scrolly set" -xscrollcommand ".scrollx set" -bg white -wrap none -font ${font1} -bg white
 scrollbar .scrollx -command ".text xview" -orient horizontal -bg $colb
 scrollbar .scrolly -command ".text yview" -bg $colb

 pack .scrolly -in .f11 -side right -fill y
 pack .scrollx -in .f11 -side bottom -fill x
 pack .text -in .f11 -side top -fill x -fill y -ipady 400

 # --------------------------------- Input -----------------------------------------
 label .l0r -text "    Input Channels      Bitmask" -font ${font3} -bg $colb
 pack .l0r -side left -in .f0r

 label .l3r -text "15:" -font ${font1} -bg $colb
 entry .e3r -width 15 -relief sunken -bd 2 -textvariable wdata(15) -bg white -font ${font1} -bg white
 bind .e3r <Return> {write_socket w 15}
 entry .e3r1 -width 15 -relief sunken -bd 2 -textvariable bmask(15) -bg white -font ${font1} -bg white
 pack .l3r .e3r .e3r1 -side left -in .f3r

 label .l4r -text "16:" -font ${font1} -bg $colb
 entry .e4r -width 15 -relief sunken -bd 2 -textvariable wdata(16) -bg white -font ${font1} -bg white
 bind .e4r <Return> {write_socket w 16}
 entry .e4r1 -width 15 -relief sunken -bd 2 -textvariable bmask(16) -bg white -font ${font1} -bg white
 pack .l4r .e4r .e4r1 -side left -in .f4r

 label .l5r -text "30:" -font ${font1} -bg $colb
 entry .e5r -width 15 -relief sunken -bd 2 -textvariable wdata(30) -bg white -font ${font1} -bg white
 bind .e5r <Return> {write_socket w 30}
 entry .e5r1 -width 15 -relief sunken -bd 2 -textvariable bmask(30) -bg white -font ${font1} -bg white
 pack .l5r .e5r .e5r1 -side left -in .f5r

 label .l6r -text "31:" -font ${font1} -bg $colb
 entry .e6r -width 15 -relief sunken -bd 2 -textvariable wdata(31) -bg white -font ${font1} -bg white
 bind .e6r <Return> {write_socket w 31}
 entry .e6r1 -width 15 -relief sunken -bd 2 -textvariable bmask(31) -bg white -font ${font1} -bg white
 pack .l6r .e6r .e6r1 -side left -in .f6r

 label .l7r -text "32:" -font ${font1} -bg $colb
 entry .e7r -width 15 -relief sunken -bd 2 -textvariable wdata(32) -bg white -font ${font1} -bg white
 bind .e7r <Return> {write_socket w 32}
 entry .e7r1 -width 15 -relief sunken -bd 2 -textvariable bmask(32) -bg white -font ${font1} -bg white
 pack .l7r .e7r .e7r1 -side left -in .f7r

 label .l8r -text "33:" -font ${font1} -bg $colb
 entry .e8r -width 15 -relief sunken -bd 2 -textvariable wdata(33) -bg white -font ${font1} -bg white
 bind .e8r <Return> {write_socket w 33}
 entry .e8r1 -width 15 -relief sunken -bd 2 -textvariable bmask(33) -bg white -font ${font1} -bg white
 pack .l8r .e8r .e8r1 -side left -in .f8r

 checkbutton .cb101 -text "Log OUT " -variable log_out_flag -relief raised -borderwidth 2 -anchor w -font ${font11} -bg $colb -pady 4
 checkbutton .cb102 -text "Log IN  " -variable log_in_flag -relief raised -borderwidth 2 -anchor w -font ${font11}  -bg $colb -pady 4
 button .b101 -text "Clear" -command {.text delete 0.0 end} -font ${font11} -bg $colb -pady 3
 pack  .cb101 .cb102 .b101 -side left -in .f9r -pady 4 -padx 1 -anchor w

 label .l_bytesout -text "Output Bytes/Sec.:" -font ${font1} -bg $colb
 entry .e_bytesout -width 7 -relief groove -bd 2 -textvariable bytesReceived -font ${font1} -bg $colb
 pack .l_bytesout .e_bytesout -side left -in .f10r

 label .l_bytesin -text "Input  Bytes/Sec.:" -font ${font1} -bg $colb
 entry .e_bytesin -width 7 -relief groove -bd 2 -textvariable bytesSent -font ${font1} -bg $colb
 pack .l_bytesin .e_bytesin -side left -in .f101r

 focus .e3r
 update
}


# **********************************************************************************************
# **** Function: Build the Menu                                                             ****
# **********************************************************************************************
proc create_menu {} {
 global font2 colb

 frame .men -relief raised -bd 2 -bg $colb

 pack .men -side top -fill x

 # ----------------------------------------- Edit ----------------------------------------------
 menubutton .men.edit -text "Edit" -menu .men.edit.m -font $font2 -bg $colb
 pack .men.edit -side left -padx 2m

 menu .men.edit.m
 .men.edit.m add command -label "Clear Message Window"  -command {.text delete 0.0 end} -font $font2
 .men.edit.m add separator
 .men.edit.m add command -label "Exit                " -underline 0 -accelerator Ctrl+x -command {exit_program} -font $font2

 # ------------------------------------- Systems Menu --------------------------------------------
 menubutton .men.ctr -text "Systems" -menu .men.ctr.m -font $font2 -bg $colb
 pack .men.ctr -side left -padx 2m

 menu .men.ctr.m
 .men.ctr.m add command -label "DSKY Lite" -command {create_dsky} -font $font2
 .men.ctr.m add separator
 .men.ctr.m add command -label "AGC Outputs" -command {create_lmsys} -font $font2
 .men.ctr.m add separator
 .men.ctr.m add command -label "AGC LM System Inputs" -command {create_sysinp} -font $font2
 .men.ctr.m add command -label "AGC Crew Inputs" -command {create_crewinp} -font $font2
 .men.ctr.m add separator
 .men.ctr.m add command -label "FDAI / IMU (Inertial Measurement Unit)" -command {create_imugui} -font $font2
 .men.ctr.m add separator
 .men.ctr.m add command -label "Simulation Monitor & Control" -command {create_attitude_gui} -font $font2

 # ------------------------------------- Info Menu -----------------------------------------------
 menubutton .men.inf -text "Info" -menu .men.inf.m -font $font2 -bg $colb
 pack .men.inf -side left -padx 2m

 menu .men.inf.m
 .men.inf.m add command -label "Help" -command {open_text "help.txt"} -font $font2
 .men.inf.m add command -label "Tutorial" -command {open_text "tutorial.txt"} -font $font2
 .men.inf.m add separator
 .men.inf.m add command -label "Verbs & Nouns" -command {open_text "verb_noun.txt"} -font $font2
 .men.inf.m add command -label "Alarm Codes" -command {open_text "alarm_codes.txt"} -font $font2
 .men.inf.m add separator
 .men.inf.m add command -label "About" -command {open_text "about.txt"} -font $font2
 .men.inf.m add command -label "License" -command {open_text "license.txt"} -font $font2
}


# *********************************************************************************************
# **** Function: Open Text Files (About, Help, Licence)                                    ****
# *********************************************************************************************
proc open_text {file} {
 global docpath font2 colb

 if {[winfo exists .op] == 1} {destroy .op}

 if {$file == "about.txt"} {
    set wmtxt "ABOUT LM System Simulator"
 } elseif {$file == "help.txt"} {
    set wmtxt "HELP of LM System Simulator"
 } elseif {$file == "license.txt"} {
    set wmtxt "GPL LICENSE of the LM System Simulator"
 } elseif {$file == "verb_noun.txt"} {
    set wmtxt "VERBS & NOUNS for LUMINARY 131/1C"
 } elseif {$file == "tutorial.txt"} {
    set wmtxt "Tutorial for LM System Simulator"
 } elseif {$file == "alarm_codes.txt"} {
    set wmtxt "ALARM CODES for LUMINARY 131/1C"
 }

 toplevel .op
 wm title .op $wmtxt
 wm geometry .op +300+300
 wm geometry .op 600x400
 wm minsize  .op 200 200
 wm iconname .op "HELP"

 .op configure -background $colb

 frame .op.f1 -bg $colb

 pack .op.f1 -side top -pady 1m

 text .op.text -relief sunken -bd 2 -yscrollcommand ".op.scrolly set" -xscrollcommand ".op.scrollx set" -bg white -font $font2 -wrap none

 scrollbar .op.scrollx -command ".op.text xview" -orient horizontal -bg $colb
 scrollbar .op.scrolly -command ".op.text yview" -bg $colb

 pack .op.scrolly -in .op.f1 -side right -fill y
 pack .op.scrollx -in .op.f1 -side bottom -fill x
 pack .op.text -in .op.f1 -side top -fill x -fill y -ipadx 1000 -ipady 1000

 set datei [open ${docpath}${file}]
 while {[gets $datei zeile] >= 0} {
       .op.text insert end "$zeile\n"
 }
 close $datei
}


# *********************************************************************************************
# **** Function: Read Config File and Command Line Parameter                               ****
# *********************************************************************************************
proc read_config_file {} {
 global path config_file serverSock serverIP config_file Operating_System
 global Descent_Propellant_Mass_KG LM_Weight_Ascent_KG LM_Weight_Descent_KG
 global Descent_Propulsion_Max_N Descent_Propulsion_Min_N Descent_Specific_Impulse_MS
 global RCS_Specific_Impulse_MS RCS_Thrust_N RCS_Propellant_Mass_KG
 global Ascent_Propellant_Mass_KG Ascent_Thrust_N Ascent_Specific_Impulse_MS FDAI_Update_Rate
 global argv argc

 set serverSock_flag 0

 # ------------ Read Command Line Parameter --------------
 if {$argc > 0} {
   for {set i 0} {$i < $argc} {incr i 1} {
      set res [string tolower [lindex $argv $i]]
      if {[string range $res 0 6] == "--port="} {set serverSock_flag 1; set serverSock [string range $res 7 end]}
      if {[string range $res 0 5] == "--cfg="} {set config_file [string range $res 6 end]}
   }
 }

 # ------------ Read Config File -------------------------
 set err [catch {set datei [open ${config_file}]}]
 if {$err == 0} {
   while {[gets $datei zeile] >= 0} {
       set t1 [string tolower [lindex $zeile 0]]
       set t2 [string tolower [lindex $zeile 1]]
       # ---- Load Simulation Initialization Values ----
       if {$t1 == "lm_weight_ascent_kg"} {set LM_Weight_Ascent_KG $t2}
       if {$t1 == "lm_weight_descent_kg"} {set LM_Weight_Descent_KG $t2}
       if {$t1 == "ascent_propellant_mass_kg"} {set  Ascent_Propellant_Mass_KG $t2}
       if {$t1 == "ascent_thrust_n"} {set  Ascent_Thrust_N $t2}
       if {$t1 == "ascent_specific_impulse_ms"} {set  Ascent_Specific_Impulse_MS $t2}
       if {$t1 == "descent_propellant_mass_kg"} {set Descent_Propellant_Mass_KG $t2}
       if {$t1 == "descent_propulsion_min_n"} {set Descent_Propulsion_Min_N $t2}
       if {$t1 == "descent_propulsion_max_n"} {set Descent_Propulsion_Max_N $t2}
       if {$t1 == "descent_specific_impulse_ms"} {set Descent_Specific_Impulse_MS $t2}
       if {$t1 == "rcs_specific_impulse_ms"} {set RCS_Specific_Impulse_MS $t2}
       if {$t1 == "rcs_thrust_n"} {set RCS_Thrust_N $t2}
       if {$t1 == "rcs_propellant_mass_kg"} {set RCS_Propellant_Mass_KG $t2}
       # ---- Load Program Configuration Parameter ----
       if {$t1 == "serverip"} {set serverIP $t2}
       if {$t1 == "serversocket" && $serverSock_flag == 0} {set serverSock $t2}
       if {$t1 == "dsky"} {if {$t2 == "on"} {create_dsky; update}}
       if {$t1 == "output"} {if {$t2 == "on"} {create_lmsys; update}}
       if {$t1 == "system"} {if {$t2 == "on"} {create_sysinp; update}}
       if {$t1 == "crew"} {if {$t2 == "on"} {create_crewinp; update}}
       if {$t1 == "imu"} {if {$t2 == "on"} {create_imugui; update}}
       if {$t1 == "attitude"} {if {$t2 == "on"} {create_attitude_gui; update}}
       if {$t1 == "operating_system"} {set Operating_System $t2}
       if {$t1 == "fdai_update_rate"} {set FDAI_Update_Rate $t2}
   }
   close $datei
 }
}


# **********************************************************************************************
# **** Function: Set useful Start Values                                                    ****
# **********************************************************************************************
proc set_ini_values {} {
 global wdata bmask b bo

 # ------------------ Set Initial Data ----------------------------
 set wdata(15)  "000000000000000"; set wdata(16)  "000000000000000"
 set wdata(30)  "011110011011001"; set wdata(31)  "111111111111111"
 set wdata(32)  "010001111111111"; set wdata(33)  "101111111111110"

 # ------------------ Set Initial Input Bit Masks -----------------
 set bmask(15) "000000000000000"; set bmask(16) "000000001111100"
 set bmask(30) "111111111111111"; set bmask(31) "111111111111111"
 set bmask(32) "000001111111111"; set bmask(33) "111111111111110"

 # ------------------ Initialize Output Array ---------------------
 foreach i {5 6 7 10 11 12 13 14 15 16 30 31 32 33 34 35 164 165 166 167 170 171 172 173 174 175 176 177} {
    for {set j 0} {$j <= 15} {incr j 1} {
        set bo($i,$j) 0
    }
 }
}


# **********************************************************************************************
# **** Function: Write Start Values into the AGC                                            ****
# **********************************************************************************************
proc write_ini_values {} {
 global wdata bmask b bo

 foreach i {16 30 31 32 33} {
    write_socket w $i
    for {set j 0} {$j <= 15} {incr j 1} {
        set b($i,[expr 15-$j]) [string index $wdata($i) $j]
    }
 }
}


# *********************************************************************************************
# **** Function: Convert Binary (11 or 14 Bits) to Decimal                                 ****
# *********************************************************************************************
proc convert_bin_dec {par1} {

   if {[string length $par1] < 13} {set par1 "000$par1"}
   set dec [string index $par1 13]
   set dec [expr $dec + [string index $par1 12] * 2]
   set dec [expr $dec + [string index $par1 11] * 4]
   set dec [expr $dec + [string index $par1 10] * 8]
   set dec [expr $dec + [string index $par1 9] * 16]
   set dec [expr $dec + [string index $par1 8] * 32]
   set dec [expr $dec + [string index $par1 7] * 64]
   set dec [expr $dec + [string index $par1 6] * 128]
   set dec [expr $dec + [string index $par1 5] * 256]
   set dec [expr $dec + [string index $par1 4] * 512]
   set dec [expr $dec + [string index $par1 3] * 1024]
   set dec [expr $dec + [string index $par1 2] * 2048]
   set dec [expr $dec + [string index $par1 1] * 4096]
   set dec [expr $dec + [string index $par1 0] * 8192]

   return $dec
}


# *********************************************************************************************
# **** Function: Convert Binary (15 Bits) to Decimal                                       ****
# *********************************************************************************************
proc convert_bin15_dec {par1} {

   set dec [string index $par1 14]
   set dec [expr $dec + [string index $par1 13] * 2]
   set dec [expr $dec + [string index $par1 12] * 4]
   set dec [expr $dec + [string index $par1 11] * 8]
   set dec [expr $dec + [string index $par1 10] * 16]
   set dec [expr $dec + [string index $par1 9] * 32]
   set dec [expr $dec + [string index $par1 8] * 64]
   set dec [expr $dec + [string index $par1 7] * 128]
   set dec [expr $dec + [string index $par1 6] * 256]
   set dec [expr $dec + [string index $par1 5] * 512]
   set dec [expr $dec + [string index $par1 4] * 1024]
   set dec [expr $dec + [string index $par1 3] * 2048]
   set dec [expr $dec + [string index $par1 2] * 4096]
   set dec [expr $dec + [string index $par1 1] * 8192]
   set dec [expr $dec + [string index $par1 0] * 16384]

   return $dec
}


# *********************************************************************************************
# **** Function: Convert Binary (7 Bits) to Octal                                          ****
# *********************************************************************************************
proc convert_bin_oct {par1} {

   set dec [string index $par1 6]
   set dec [expr $dec + [string index $par1 5] * 2]
   set dec [expr $dec + [string index $par1 4] * 4]
   set dec [expr $dec + [string index $par1 3] * 8]
   set dec [expr $dec + [string index $par1 2] * 16]
   set dec [expr $dec + [string index $par1 1] * 32]
   set dec [expr $dec + [string index $par1 0] * 64]

   return [format %o $dec]
}


# *********************************************************************************************
# **** Function: Convert Octal to Binary (7 Bits)                                          ****
# *********************************************************************************************
proc convert_oct_bin {par1} {

   set res [format %d 0$par1]
   set res2 [format %c $res]
   binary scan $res2 B8 res

   return [string range $res 1 7]
}


# *********************************************************************************************
# **** Function: Open Client Socket Connection                                             ****
# *********************************************************************************************
proc open_socket {} {
 global serverIP serverSock sockChan

 set err [catch {set sockChan [socket $serverIP $serverSock]}]
 if {$err != 0} {ShowMessageBox "error" "Can't connect to yaAGC!"; exit_program}
 fconfigure ${sockChan} -blocking 0 -buffering none -buffersize 0 -encoding binary
}


# *********************************************************************************************
# **** Function: Read 4 Bytes (Sync: 00 01 10 11) from Socket (Main Loop)                  ****
# *********************************************************************************************
proc read_socket {} {
 global sockChan ChanData
 global Simulation_Timer Simulation_Timer_Init Delta_Time Delta_Time2
 global JET_FLAG flash_flag button_flag bytesReceived bytesSent bytesSentCount FDAI_Update_Rate

 set sync            ""
 set res2            ""
 set Delta_Time_int  0
 set Delta_Time3     0
 set Delta_Time4     0
 set Delta_Time5     0
 set zeit            0
 set i               5
 set bytesReceivedCount 0
 set FDAI_Update_Rate [expr 1.0 / $FDAI_Update_Rate]

 # ---- Main Loop ----
 while {1} {
   # ---- Read Data from the Socket ----
   set res [read $sockChan 1]
   if {$res == ""} {
     # ---- Dynamic CPU Load Control and Dynamic Simulation ----
     set t [expr abs([clock clicks -milliseconds])]
     set Delta_Time_int [expr abs($Simulation_Timer_Init - $t)]
     set Delta_Time [expr $Delta_Time_int / 1000.0]
     set Delta_Time2 [expr $Delta_Time2 + $Delta_Time]
     set Simulation_Timer [expr $Simulation_Timer + $Delta_Time]
     set Simulation_Timer_Init $t
     if {$JET_FLAG == 1} {update_RCS; set zeit 5} else {set zeit 10}
     # ---- Update Dynamic Model - Every 25ms ----
     if {$Delta_Time2 > 0.025} {
       dynamic_simulation
       set Delta_Time3 [expr $Delta_Time3 + $Delta_Time2]
       set Delta_Time4 [expr $Delta_Time4 + $Delta_Time2]
       set Delta_Time5 [expr $Delta_Time5 + $Delta_Time2]
       set Delta_Time2 0
       # ---- DSKY Flash Signal every 300ms ----
       if {$Delta_Time3 > 0.3} {
         if {$flash_flag == 0} {set flash_flag 1} else {set flash_flag 0}
         set Delta_Time3 0
       }
       # ---- Update FDAI every 100ms ----
       if {$Delta_Time4 > $FDAI_Update_Rate} {
         move_fdai_marker
         set Delta_Time4 0
       }
       # ---- Byte Received Counter ----
       if {$Delta_Time5 > 1.0} {
         set Delta_Time5 0
         set bytesReceived $bytesReceivedCount
         set bytesSent $bytesSentCount
         set bytesReceivedCount 0
         set bytesSentCount 0
       }
     }
     # ---- Wait Cycle ----
     after $zeit {set zeit 0}; tkwait variable zeit
   } else {
     # ---- Look for Sync. and Evaluate the Data ----
     binary scan $res B2 sync
     incr bytesReceivedCount
     if {$sync == "00"} {set i 0}
     if {$sync != 01 && $i == 1} {set i 5}
     if {$sync != 10 && $i == 2} {set i 5}
     if {$sync != 11 && $i == 3} {set i 5}
     if {$i < 5} {binary scan $res B8 res2; set ChanData($i) $res2; incr i 1}
     if {$i == 4} {
       process_data
       dsky_signals
       update
     }
   }
 }
}


# *********************************************************************************************
# **** Function: Process AGC Output (Channel Data and Unprogrammed Sequences)              ****
# *********************************************************************************************
proc process_data {} {
 global ChanData cdata log_out_flag bo unpSeq colb colact pulse_count_x pulse_count_y pulse_count_z
 global m4 JET_FLAG
 global Q4U Q4D Q3U Q3D 
 global Q2U Q2D Q1U Q1D
 global Q3A Q4F Q1F Q2A
 global Q2L Q3R Q4R Q1L

 set data "$ChanData(0)$ChanData(1)$ChanData(2)$ChanData(3)"
 set t [string index $data 3]
 set channel [string range $data 4 7][string range $data  10 12]
 set octChannel [convert_bin_oct $channel]
 set tmp2 0


 if {$t == 0} {
   set cdata($octChannel) [string range $data 13 15][string range $data 18 23][string range $data 26 31]

   # ---- Gyro Fine Align if Octal Channel = 0177 ----
   if {$octChannel == 177} {gyro_fine_align} 
   # ----------------------------------------------

   # ---- Gyro Coarse Align if Octal Channel = 0174; 0175; 0176 ----
   if {$octChannel == 174 || $octChannel == 175 || $octChannel == 176} {gyro_coarse_align $octChannel}
   # ---------------------------------------------------------------

   # ---- Joystick Channel ----
   #if {$octChannel == 31 || $octChannel == 166 || $octChannel == 167 || $octChannel == 170} {read_joystick $octChannel}

   # ---- Heart Beat ----
   #if {$octChannel == 165} {
   #  .text insert end "HB: $cdata(165)\n"
   #  .text yview moveto 1
   #}

   # ---- Check if there is a Jet Firing on Channel 5 or 6 ----
   if {$octChannel == 5 || $octChannel == 6} {
     set Q4U $bo(5,1); set Q4D $bo(5,2); set Q3U $bo(5,3); set Q3D $bo(5,4)
     set Q2U $bo(5,5); set Q2D $bo(5,6); set Q1U $bo(5,7); set Q1D $bo(5,8)

     set Q3A $bo(6,1); set Q4F $bo(6,2); set Q1F $bo(6,3); set Q2A $bo(6,4)
     set Q2L $bo(6,5); set Q3R $bo(6,6); set Q4R $bo(6,7); set Q1L $bo(6,8)

     if {$Q4U == 0 && $Q4D == 0 && $Q3U == 0 && $Q3D == 0 && $Q2U == 0 && $Q2D == 0 && $Q1U == 0 && $Q1D == 0 && $Q3A == 0 && $Q4F == 0 && $Q1F == 0 && $Q2A == 0 && $Q2L == 0 && $Q3R == 0 && $Q4R == 0 && $Q1L == 0} {set JET_FLAG 0} else {set JET_FLAG 1}
   }

   for {set j 0} {$j <= 15} {incr j 1} {
     set bit [expr 15-$j]
     set tmp [string index $cdata($octChannel) $j]
     catch {set tmp2 $bo($octChannel,$bit)}
     if {$tmp != $tmp2} {
       set bo($octChannel,$bit) $tmp
       # ---------------- Set Output Signals -------------------
       if {[winfo exists .lmsys] == 1 && ($octChannel == 5 || $octChannel == 6 || $octChannel == 11 || $octChannel == 12 || $octChannel == 13 || $octChannel == 14)} {
         if {$bo($octChannel,$bit) == 1} {
           catch {.lmsys.l_${octChannel}_${bit} configure -background $colact}
         } else {
           catch {.lmsys.l_${octChannel}_${bit} configure -background $colb}
         }
       }
     }
   }

   # ---------------- Check if Zero IMU CDU is active ------------------
   if {$bo(12,5) == 1 && $m4 == 0} {zeroIMU; set m4 1} elseif {$bo(12,5) == 0 && $m4 == 1} {set m4 0}

   if {$log_out_flag == 1} {
     catch {.text insert end "Out: [format %2d $octChannel]  $channel  $cdata($octChannel)\n"}
     .text yview moveto 1
   }
 } else {
   if {$log_out_flag == 1} {
     set temp [string range $data 13 15][string range $data 18 23][string range $data 26 31]
     catch {.text insert end "Out: [format %2d $octChannel]  $channel  $temp  US: $unpSeq($temp)\n"}
     .text yview moveto 1
   }
 }
}


# *********************************************************************************************
# **** Function: Write to Socket (Bitmask; Input Channel and Unprogrammed Sequences)       ****
# *********************************************************************************************
proc write_socket {par0 par1} {
 global sockChan wdata bmask b unpSeq log_in_flag bytesSentCount

 if {$par0 == "b"} {
   set wdata($par1) ""
   for {set j 15} {$j >= 0} {incr j -1} {set wdata($par1) $wdata($par1)$b($par1,$j)}
 }

 if {$par0 == "w"} {
   for {set j 0} {$j <= 15} {incr j 1} {set b($par1,[expr 15-$j]) [string index $wdata($par1) $j]}
 }

 set channel [convert_oct_bin $par1]

 if {$par0 == "b" || $par0 == "w"} {
   if {$log_in_flag == 1} {
     .text insert end "In:  [format %2d $par1]  $channel  $wdata($par1)  $bmask($par1)\n"
     .text yview moveto 1
   }
   set cd1 "0010[string range $channel 0 3]"
   set cd2 "01[string range $channel 4 6][string range $bmask($par1) 0 2]"
   set cd3 "10[string range $bmask($par1) 3 8]"
   set cd4 "11[string range $bmask($par1) 9 14]"

   puts -nonewline $sockChan [binary format B8 $cd1]
   puts -nonewline $sockChan [binary format B8 $cd2]
   puts -nonewline $sockChan [binary format B8 $cd3]
   puts -nonewline $sockChan [binary format B8 $cd4]
   set bytesSentCount [expr $bytesSentCount + 4]

   set cd1 "0000[string range $channel 0 3]"
   set cd2 "01[string range $channel 4 6][string range $wdata($par1) 0 2]"
   set cd3 "10[string range $wdata($par1) 3 8]"
   set cd4 "11[string range $wdata($par1) 9 14]"
 } else {
   if {$log_in_flag == 1} {
     #.text insert end "IN:  [format %2d $par1]  $channel  $unpSeq($par0)  US: $par0\n"
     #.text yview moveto 1
   }

   set cd1 "0001[string range $channel 0 3]"
   set cd2 "01[string range $channel 4 6][string range $unpSeq($par0) 0 2]"
   set cd3 "10[string range $unpSeq($par0) 3 8]"
   set cd4 "11[string range $unpSeq($par0) 9 14]"
 }

 puts -nonewline $sockChan [binary format B8 $cd1]
 puts -nonewline $sockChan [binary format B8 $cd2]
 puts -nonewline $sockChan [binary format B8 $cd3]
 puts -nonewline $sockChan [binary format B8 $cd4]
 set bytesSentCount [expr $bytesSentCount + 4]

 flush $sockChan
}


# *********************************************************************************************
# **** Function: Show Message Box                                                          ****
# *********************************************************************************************
proc ShowMessageBox {par1 par2} {
 global font1

 set reply [tk_messageBox -default ok -icon ${par1} -message ${par2} -parent . -title "LM System Simulator" -type ok]
}


# *********************************************************************************************
# **** Function: Start Subprocess yaAGC (for Windows stand-alone Version only)             ****
# *********************************************************************************************
proc start_yaAGC {} {
 global path
 
 catch {exec cmd.exe /c ${path}yaAGC.bat &}
 set zeit 200; after $zeit {set zeit 0}; tkwait variable zeit
}


# *********************************************************************************************
# **** Function: Exit Program                                                              ****
# *********************************************************************************************
proc exit_program {} {

 exit 0
}


# *********************************************************************************************
# **** Read Sources                                                                        ****
# *********************************************************************************************

# ----------------------------- Source: AGC DSKY ----------------------------------------------
source $source0

# ----------------------------- Source: AGC Outputs -------------------------------------------
source $source1

# ----------------------------- Source: AGC System Inputs -------------------------------------
source $source2

# ----------------------------- Source: AGC Crew Inputs ---------------------------------------
source $source3

# ----------------------------- Source: AGC IMU -----------------------------------------------
source $source4

# ----------------------------- Source: AGC Attitude ------------------------------------------
source $source5


# *********************************************************************************************
# **** Function: Main                                                                      ****
# *********************************************************************************************
#start_yaAGC
open_socket
set_ini_values
write_ini_values
read_config_file
create_gui
read_socket
