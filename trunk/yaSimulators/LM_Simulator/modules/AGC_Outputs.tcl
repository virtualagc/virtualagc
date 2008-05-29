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

# ********************************************************************************************
# **** Module:         AGC_Outputs.tcl                                                    ****
# **** Main Program:   lm_system_simulator                                                ****
# **** Author:         Stephan Hotto                                                      ****
# **** Date/Location:  21.04.07/Germany                                                   ****
# **** Version:        v1.0                                                               ****
# ********************************************************************************************

# ********************************************************************************************
# **** Function:  Create AGC Outputs GUI                                                  ****
# ********************************************************************************************
proc create_lmsys {} {
 global bo font11 font11b font1 font2 font3 colb colact Operating_System

 if {[winfo exists .lmsys] == 1} {destroy .lmsys}

 toplevel .lmsys -background $colb
 wm title .lmsys "AGC Outputs"
 if {$Operating_System == "linux"} {
   wm geometry .lmsys +455+0; wm geometry .lmsys 630x430; wm minsize  .lmsys 630 430
 } else {
   wm geometry .lmsys +457+0; wm geometry .lmsys 710x470; wm minsize  .lmsys 710 470
 }
 wm iconname .lmsys "AGC Outputs" 

 frame .lmsys.fma -bg $colb; frame .lmsys.fmb -bg $colb; frame .lmsys.fmc -bg $colb; frame .lmsys.fmd -bg $colb;

 pack .lmsys.fma .lmsys.fmb .lmsys.fmc .lmsys.fmd -side left -anchor n -pady 1 -padx 10

 # --------------------- Checkbutton as Signal Indicator --------------------------
 # --------------------- 1st column -----------------------------------------------
 label .lmsys.l0a -text "DSKY:" -font ${font11b} -bg $colb
 pack  .lmsys.l0a -side top -in .lmsys.fma -anchor w -pady 1

 label .lmsys.l_11_2 -text "COMPUTER ACTIVITY    " -font ${font11} -bg $colb
 pack .lmsys.l_11_2 -side top -in .lmsys.fma -anchor w -pady 1

 label .lmsys.l_11_3 -text "UPLINK ACTIVITY      " -font ${font11} -bg $colb
 pack .lmsys.l_11_3 -side top -in .lmsys.fma -anchor w -pady 1

 label .lmsys.l_11_4 -text "TEMPERATURE CAUTION  " -font ${font11} -bg $colb
 pack .lmsys.l_11_4 -side top -in .lmsys.fma -anchor w -pady 1

 label .lmsys.l_11_5 -text "KEYBOARD RELEASE     " -font ${font11} -bg $colb
 pack .lmsys.l_11_5 -side top -in .lmsys.fma -anchor w -pady 1

 label .lmsys.l_11_6 -text "FLASH VERB & NOUN    " -font ${font11} -bg $colb
 pack .lmsys.l_11_6 -side top -in .lmsys.fma -anchor w -pady 1

 label .lmsys.l_11_7 -text "OPERATOR ERROR       " -font ${font11} -bg $colb
 pack .lmsys.l_11_7 -side top -in .lmsys.fma -anchor w -pady 1

 label .lmsys.l_13_10 -text "TEST ALARMS,\nTEST DSKY LIGHTS     " -font ${font11} -justify left -bg $colb
 pack .lmsys.l_13_10 -side top -in .lmsys.fma -anchor w -pady 1

 label .lmsys.l_11_1 -text "ISS Warning          " -font ${font11} -bg $colb
 pack .lmsys.l_11_1 -side top -in .lmsys.fma -anchor w -pady 1

 label .lmsys.l9a -text "COMMON:" -font ${font11b} -bg $colb
 pack  .lmsys.l9a -side top -in .lmsys.fma -anchor w -pady 1

 label .lmsys.l_11_9 -text "TEST CONNECTOR OUTBIT" -font ${font11} -bg $colb
 pack .lmsys.l_11_9 -side top -in .lmsys.fma -anchor w -pady 1

 label .lmsys.l_11_10 -text "CAUTION RESET        " -font ${font11} -bg $colb
 pack .lmsys.l_11_10 -side top -in .lmsys.fma -anchor w -pady 1

 label .lmsys.l_13_11 -text "ENABLE STANDBY       " -font ${font11} -bg $colb
 pack .lmsys.l_13_11 -side top -in .lmsys.fma -anchor w -pady 1

 label .lmsys.l_13_12 -text "RESET TRAP 31-A      " -font ${font11} -bg $colb
 pack .lmsys.l_13_12 -side top -in .lmsys.fma -anchor w -pady 1

 label .lmsys.l_13_13 -text "RESET TRAP 31-B      " -font ${font11} -bg $colb
 pack .lmsys.l_13_13 -side top -in .lmsys.fma -anchor w -pady 1

 label .lmsys.l_13_14 -text "RESET TRAP 32        " -font ${font11} -bg $colb
 pack .lmsys.l_13_14 -side top -in .lmsys.fma -anchor w -pady 1

 label .lmsys.l_13_15 -text "ENABLE T6 RUPT       " -font ${font11} -bg $colb
 pack .lmsys.l_13_15 -side top -in .lmsys.fma -anchor w -pady 1

 label .lmsys.l_12_15 -text "ISS TURN ON\nDELAY COMPLETE       " -font ${font11} -justify left -bg $colb
 pack .lmsys.l_12_15 -side top -in .lmsys.fma -anchor w -pady 1

 label .lmsys.l_13_7 -text "DOWNLINK TELEMETRY\nWORD ORDER CODE BIT  " -font ${font11} -justify left -bg $colb
 pack .lmsys.l_13_7 -side top -in .lmsys.fma -anchor w -pady 1

 # --------------------- 2nd column --------------------------------------------- 
 label .lmsys.l0b -text "Engine:" -font ${font11b} -bg $colb
 pack  .lmsys.l0b -side top -in .lmsys.fmb -anchor w -pady 1

 label .lmsys.l_11_13 -text "ENGINE ON            " -font ${font11} -bg $colb
 pack .lmsys.l_11_13 -side top -in .lmsys.fmb -anchor w -pady 1

 label .lmsys.l_11_14 -text "ENGINE OFF           " -font ${font11} -bg $colb
 pack .lmsys.l_11_14 -side top -in .lmsys.fmb -anchor w -pady 1

 label .lmsys.l_12_9 -text "-PITCH GIMBAL TRIM   " -font ${font11} -bg $colb
 pack .lmsys.l_12_9 -side top -in .lmsys.fmb -anchor w -pady 1

 label .lmsys.l_12_10 -text "+PITCH GIMBAL TRIM   " -font ${font11} -bg $colb
 pack .lmsys.l_12_10 -side top -in .lmsys.fmb -anchor w -pady 1

 label .lmsys.l_12_11 -text "-ROLL GIMBAL TRIM    " -font ${font11} -bg $colb
 pack .lmsys.l_12_11 -side top -in .lmsys.fmb -anchor w -pady 1

 label .lmsys.l_12_12 -text "+ROLL GIMBAL TRIM    " -font ${font11} -bg $colb
 pack .lmsys.l_12_12 -side top -in .lmsys.fmb -anchor w -pady 1

 label .lmsys.l_14_4 -text "THRUST DRIVE ACTIVITY\nFOR DESCENT ENGINE" -font ${font11} -justify left -bg $colb
 pack .lmsys.l_14_4 -side top -in .lmsys.fmb -anchor w -pady 1

 label .lmsys.l8b -text "RCS JET CONTROL:" -font ${font11b} -bg $colb
 pack  .lmsys.l8b -side top -in .lmsys.fmb -anchor w -pady 1

 frame .lmsys.f1b -bg $colb
 pack  .lmsys.f1b -side top -in .lmsys.fmb -anchor w

 label .lmsys.l9b -text "Quad 1     Quad 4" -font ${font11} -bg $colb
 pack  .lmsys.l9b -side top -in .lmsys.f1b -anchor w -pady 1

 label .lmsys.l_5_8 -text "D" -font ${font11} -bg $colb
 pack .lmsys.l_5_8 -side left -in .lmsys.f1b -anchor w -pady 1 -ipadx 5

 label .lmsys.l_6_3 -text "F" -font ${font11} -bg $colb
 pack .lmsys.l_6_3 -side left -in .lmsys.f1b -anchor w -pady 1 -ipadx 5

 label .lmsys.l_s1 -text " " -font ${font11} -bg $colb
 pack .lmsys.l_s1 -side left -in .lmsys.f1b -anchor w -pady 1 -ipadx 5

 label .lmsys.l_6_2 -text "F" -font ${font11} -bg $colb
 pack .lmsys.l_6_2 -side left -in .lmsys.f1b -anchor w -pady 1 -ipadx 5

 label .lmsys.l_5_2 -text "D" -font ${font11} -bg $colb
 pack .lmsys.l_5_2 -side left -in .lmsys.f1b -anchor w -pady 1 -ipadx 5

 frame .lmsys.f2b -bg $colb
 pack  .lmsys.f2b -side top -in .lmsys.fmb -anchor w

 label .lmsys.l_6_8 -text "L" -font ${font11} -bg $colb
 pack .lmsys.l_6_8 -side left -in .lmsys.f2b -anchor w -pady 1 -ipadx 5

 label .lmsys.l_5_7 -text "U" -font ${font11} -bg $colb
 pack .lmsys.l_5_7 -side left -in .lmsys.f2b -anchor w -pady 1 -ipadx 5

 label .lmsys.l_s2 -text " " -font ${font11} -bg $colb
 pack .lmsys.l_s2 -side left -in .lmsys.f2b -anchor w -pady 1 -ipadx 5

 label .lmsys.l_5_1 -text "U" -font ${font11} -bg $colb
 pack .lmsys.l_5_1 -side left -in .lmsys.f2b -anchor w -pady 1 -ipadx 5

 label .lmsys.l_6_7 -text "R" -font ${font11} -bg $colb
 pack .lmsys.l_6_7 -side left -in .lmsys.f2b -anchor w -pady 1 -ipadx 5 

 frame .lmsys.f3b -bg $colb
 pack  .lmsys.f3b -side top -in .lmsys.fmb -anchor w 

 label .lmsys.l10b -text "Quad 2     Quad 3" -font ${font11} -bg $colb
 pack  .lmsys.l10b -side top -in .lmsys.f3b -anchor w -pady 1

 label .lmsys.l_6_5 -text "L" -font ${font11} -bg $colb
 pack .lmsys.l_6_5 -side left -in .lmsys.f3b -anchor w -pady 1 -ipadx 5

 label .lmsys.l_5_5 -text "U" -font ${font11} -bg $colb
 pack .lmsys.l_5_5 -side left -in .lmsys.f3b -anchor w -pady 1 -ipadx 5

 label .lmsys.l_s3 -text " " -font ${font11} -bg $colb
 pack .lmsys.l_s3 -side left -in .lmsys.f3b -anchor w -pady 1 -ipadx 5

 label .lmsys.l_5_3 -text "U" -font ${font11} -bg $colb
 pack .lmsys.l_5_3 -side left -in .lmsys.f3b -anchor w -pady 1 -ipadx 5 

 label .lmsys.l_6_6 -text "R" -font ${font11} -bg $colb
 pack .lmsys.l_6_6 -side left -in .lmsys.f3b -anchor w -pady 1 -ipadx 5 

 frame .lmsys.f4b -bg $colb
 pack  .lmsys.f4b -side top -in .lmsys.fmb -anchor w

 label .lmsys.l_5_6 -text "D" -font ${font11} -bg $colb
 pack .lmsys.l_5_6 -side left -in .lmsys.f4b -anchor w -pady 1 -ipadx 5

 label .lmsys.l_6_4 -text "A" -font ${font11} -bg $colb
 pack .lmsys.l_6_4 -side left -in .lmsys.f4b -anchor w -pady 1 -ipadx 5 

 label .lmsys.l_s4 -text " " -font ${font11} -bg $colb
 pack .lmsys.l_s4 -side left -in .lmsys.f4b -anchor w -pady 1 -ipadx 5

 label .lmsys.l_6_1 -text "A" -font ${font11} -bg $colb
 pack .lmsys.l_6_1 -side left -in .lmsys.f4b -anchor w -pady 1 -ipadx 5

 label .lmsys.l_5_4 -text "D" -font ${font11} -bg $colb
 pack .lmsys.l_5_4 -side left -in .lmsys.f4b -anchor w -pady 1 -ipadx 5

 label .lmsys.26b -text "HAND CONTROLLER:" -font ${font11b} -justify left -bg $colb
 pack  .lmsys.26b -side top -in .lmsys.fmb -anchor w -pady 1

 label .lmsys.l_13_8 -text "RHC COUNTER ENABLE\nREAD ANGLES          " -font ${font11} -justify left -bg $colb
 pack .lmsys.l_13_8 -side top -in .lmsys.fmb -anchor w -pady 1

 label .lmsys.l_13_9 -text "START RHC READ INTO\nCOUNTERS             " -font ${font11} -justify left -bg $colb
 pack .lmsys.l_13_9 -side top -in .lmsys.fmb -anchor w -pady 1

 # --------------------- 3rd column ---------------------------------------------
 label .lmsys.l0c -text "CDU:" -font ${font11b} -justify left -bg $colb
 pack  .lmsys.l0c -side top -in .lmsys.fmc -anchor w -pady 1

 label .lmsys.l_12_1 -text "ZERO RRADAR CDU      " -font ${font11} -bg $colb
 pack .lmsys.l_12_1 -side top -in .lmsys.fmc -anchor w -pady 1

 label .lmsys.l_12_2 -text "ENABLE CDU RADAR\nERROR COUNTER        " -font ${font11} -justify left -bg $colb
 pack .lmsys.l_12_2 -side top -in .lmsys.fmc -anchor w -pady 1

 label .lmsys.l_12_5 -text "ZERO IMU CDU         " -font ${font11} -bg $colb
 pack .lmsys.l_12_5 -side top -in .lmsys.fmc -anchor w -pady 1

 label .lmsys.l_12_6 -text "ENABLE CDU IMU\nERROR COUNTER        " -font ${font11} -justify left -bg $colb
 pack .lmsys.l_12_6 -side top -in .lmsys.fmc -anchor w -pady 1

 label .lmsys.l_14_11 -text "DRIVE CDU S          " -font ${font11} -bg $colb
 pack .lmsys.l_14_11 -side top -in .lmsys.fmc -anchor w -pady 1

 label .lmsys.l_14_12 -text "DRIVE CDU T          " -font ${font11} -bg $colb
 pack .lmsys.l_14_12 -side top -in .lmsys.fmc -anchor w -pady 1

 label .lmsys.l_14_13 -text "DRIVE CDU Z          " -font ${font11} -bg $colb
 pack .lmsys.l_14_13 -side top -in .lmsys.fmc -anchor w -pady 1

 label .lmsys.l_14_14 -text "DRIVE CDU Y          " -font ${font11} -bg $colb
 pack .lmsys.l_14_14 -side top -in .lmsys.fmc -anchor w -pady 1

 label .lmsys.l_14_15 -text "DRIVE CDU X          " -font ${font11} -bg $colb
 pack .lmsys.l_14_15 -side top -in .lmsys.fmc -anchor w -pady 1

 label .lmsys.l5c -text "IMU:" -font ${font11b} -bg $colb
 pack  .lmsys.l5c -side top -in .lmsys.fmc -anchor w -pady 1

 label .lmsys.l_12_4 -text "COARSE ALIGN\nENABLE OF IMU        " -font ${font11} -justify left -bg $colb
 pack .lmsys.l_12_4 -side top -in .lmsys.fmc -anchor w -pady 1

 label .lmsys.l_12_8 -text "DISPLAY INERTIAL DATA" -font ${font11} -bg $colb
 pack .lmsys.l_12_8 -side top -in .lmsys.fmc -anchor w -pady 1

 label .lmsys.l_14_6 -text "GYRO ENABLE POWER\nFOR PULSES           " -font ${font11} -justify left -bg $colb
 pack .lmsys.l_14_6 -side top -in .lmsys.fmc -anchor w -pady 1

 label .lmsys.l_14_7 -text "GYRO SELECT B        " -font ${font11} -bg $colb
 pack .lmsys.l_14_7 -side top -in .lmsys.fmc -anchor w -pady 1

 label .lmsys.l_14_8 -text "GYRO SELECT A        " -font ${font11} -bg $colb
 pack .lmsys.l_14_8 -side top -in .lmsys.fmc -anchor w -pady 1

 label .lmsys.l_14_9 -text "GYRO TORQUING COMMAND\nIN NEGATIVE DIRECTION" -font ${font11} -justify left -bg $colb
 pack .lmsys.l_14_9 -side top -in .lmsys.fmc -anchor w -pady 1

 label .lmsys.l_14_10 -text "GYRO ACTIVITY        " -font ${font11} -bg $colb
 pack .lmsys.l_14_10 -side top -in .lmsys.fmc -anchor w -pady 1

 # --------------------- 4th column ---------------------------------------------
 label .lmsys.l0d -text "RADAR:" -font ${font11b} -bg $colb
 pack  .lmsys.l0d -side top -in .lmsys.fmd -anchor w -pady 1

 label .lmsys.l_12_13 -text "LR POSITION 2 COMMAND  " -font ${font11} -bg $colb
 pack .lmsys.l_12_13 -side top -in .lmsys.fmd -anchor w -pady 1

 label .lmsys.l_12_14 -text "ENABLE RENDEZVOUS\nRADAR LOCK-ON          " -font ${font11} -justify left -bg $colb
 pack .lmsys.l_12_14 -side top -in .lmsys.fmd -anchor w -pady 1

 label .lmsys.l_13_1 -text "RADAR C                " -font ${font11} -bg $colb
 pack .lmsys.l_13_1 -side top -in .lmsys.fmd -anchor w -pady 1

 label .lmsys.l_13_2 -text "RADAR B                " -font ${font11} -bg $colb
 pack .lmsys.l_13_2 -side top -in .lmsys.fmd -anchor w -pady 1

 label .lmsys.l_13_3 -text "RADAR A                " -font ${font11} -bg $colb
 pack .lmsys.l_13_3 -side top -in .lmsys.fmd -anchor w -pady 1

 label .lmsys.l_13_4 -text "RADAR ACTIVITY         " -font ${font11} -bg $colb
 pack .lmsys.l_13_4 -side top -in .lmsys.fmd -anchor w -pady 1

 label .lmsys.l7d -text "ALTITUDE:" -font ${font11b} -bg $colb
 pack  .lmsys.l7d -side top -in .lmsys.fmd -anchor w -pady 1

 label .lmsys.l_14_2 -text "ALTITUDE RATE OR\nALTITUDE SELECTOR      " -font ${font11} -justify left -bg $colb
 pack .lmsys.l_14_2 -side top -in .lmsys.fmd -anchor w -pady 1

 label .lmsys.l_14_3 -text "ALTITUDE METER ACTIVITY" -font ${font11} -bg $colb
 pack .lmsys.l_14_3 -side top -in .lmsys.fmd -anchor w -pady 1
}

