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
# **** Module:         AGC_Crew_Inputs.tcl                                                ****
# **** Main Program:   lm_system_simulator                                                ****
# **** Author:         Stephan Hotto                                                      ****
# **** Date/Location:  21.04.07/Germany                                                   ****
# **** Version:        v1.0                                                               ****
# ********************************************************************************************

# ********************************************************************************************
# **** Function:  Create AGC Crew Inputs GUI                                              ****
# ********************************************************************************************
proc create_crewinp {} {
 global b bo font1 font11 font11b font2 font3 colb Operating_System
 global RHC THC DAPMODE RHCRoll RHCPitch RHCYaw

 if {[winfo exists .crewinp] == 1} {destroy .crewinp}

 toplevel .crewinp -background $colb
 wm title .crewinp "AGC Crew Inputs (Switches, Buttons, RHC/ACA, THC)"
 wm geometry .crewinp +160+160
 if {$Operating_System == "linux"} {
   wm geometry .crewinp 590x390; wm minsize .crewinp 590 390
 } else {
   wm geometry .crewinp 655x495; wm minsize .crewinp 655 495
 }
 wm iconname .crewinp "AGC Crew Inputs"

 frame .crewinp.fma -bg $colb; frame .crewinp.fmb -bg $colb; frame .crewinp.fmc -bg $colb; frame .crewinp.fmd -bg $colb;

 pack .crewinp.fma .crewinp.fmb .crewinp.fmc .crewinp.fmd -side left -anchor n -pady 1 -padx 15

 # --------------------- Checkbutton as Signal Indicator --------------------------
 # --------------------- 1st column -----------------------------------------------
 label .crewinp.l0a -text "ENGINE:" -font ${font11b} -bg $colb
 pack  .crewinp.l0a -side top -in .crewinp.fma -anchor w

 checkbutton .crewinp.cb1a -text "ENGINE ARMED SIGNAL" -variable b(30,3) -relief raised -borderwidth 2 -anchor w -font ${font11} -onvalue "0" -offvalue "1" -command {set bmask(30) "000000000000100"; write_socket b 30} -bg $colb
 pack .crewinp.cb1a -side top -in .crewinp.fma -anchor w -fill x -pady 1

 checkbutton .crewinp.cb2a -text "AUTO THROTTLE\nCOMPUTER CONTROL OF DESCENT" -variable b(30,5) -relief raised -borderwidth 2 -anchor w -font ${font11} -onvalue "0" -offvalue "1" -command {set bmask(30) "000000000010000"; write_socket b 30} -justify left -bg $colb
 pack .crewinp.cb2a -side top -in .crewinp.fma -anchor w -fill x -pady 1

 checkbutton .crewinp.cb3a -text "DESCENT ENGINE\nDISABLED BY CREW" -variable b(32,9) -relief raised -borderwidth 2 -anchor w -font ${font11} -onvalue "0" -offvalue "1" -command {set bmask(32) "000000100000000"; write_socket b 32} -justify left -bg $colb
 pack .crewinp.cb3a -side top -in .crewinp.fma -anchor w -fill x -pady 1

 checkbutton .crewinp.cb4a -text "APPARENT DESCENT ENGINE\nGIMBAL FAILURE" -variable b(32,10) -relief raised -borderwidth 2 -anchor w -font ${font11} -onvalue "0" -offvalue "1" -command {set bmask(32) "000001000000000"; write_socket b 32} -justify left -bg $colb
 pack .crewinp.cb4a -side top -in .crewinp.fma -anchor w -fill x -pady 1

 label .crewinp.l5a -text "THRUSTERS:" -font ${font11b} -bg $colb
 pack  .crewinp.l5a -side top -in .crewinp.fma -anchor w

 checkbutton .crewinp.cb6a -text "THRUSTERS 2&4 DISABLED" -variable b(32,1) -relief raised -borderwidth 2 -anchor w -font ${font11} -onvalue "0" -offvalue "1" -command {set bmask(32) "000000000000001"; write_socket b 32} -justify left -bg $colb
 pack .crewinp.cb6a -side top -in .crewinp.fma -anchor w -fill x -pady 1

 checkbutton .crewinp.cb7a -text "THRUSTERS 5&8 DISABLED" -variable b(32,2) -relief raised -borderwidth 2 -anchor w -font ${font11} -onvalue "0" -offvalue "1" -command {set bmask(32) "000000000000010"; write_socket b 32} -justify left -bg $colb
 pack .crewinp.cb7a -side top -in .crewinp.fma -anchor w -fill x -pady 1

 checkbutton .crewinp.cb8a -text "THRUSTERS 1&3 DISABLED" -variable b(32,3) -relief raised -borderwidth 2 -anchor w -font ${font11} -onvalue "0" -offvalue "1" -command {set bmask(32) "000000000000100"; write_socket b 32} -justify left -bg $colb
 pack .crewinp.cb8a -side top -in .crewinp.fma -anchor w -fill x -pady 1

 checkbutton .crewinp.cb9a -text "THRUSTERS 6&7 DISABLED" -variable b(32,4) -relief raised -borderwidth 2 -anchor w -font ${font11} -onvalue "0" -offvalue "1" -command {set bmask(32) "000000000001000"; write_socket b 32} -justify left -bg $colb
 pack .crewinp.cb9a -side top -in .crewinp.fma -anchor w -fill x -pady 1

 checkbutton .crewinp.cb10a -text "THRUSTERS 14&16 DISABLED" -variable b(32,5) -relief raised -borderwidth 2 -anchor w -font ${font11} -onvalue "0" -offvalue "1" -command {set bmask(32) "000000000010000"; write_socket b 32} -justify left -bg $colb
 pack .crewinp.cb10a -side top -in .crewinp.fma -anchor w -fill x -pady 1

 checkbutton .crewinp.cb11a -text "THRUSTERS 13&15 DISABLED" -variable b(32,6) -relief raised -borderwidth 2 -anchor w -font ${font11} -onvalue "0" -offvalue "1" -command {set bmask(32) "000000000100000"; write_socket b 32} -justify left -bg $colb
 pack .crewinp.cb11a -side top -in .crewinp.fma -anchor w -fill x -pady 1

 checkbutton .crewinp.cb12a -text "THRUSTERS 9&12 DISABLED" -variable b(32,7) -relief raised -borderwidth 2 -anchor w -font ${font11} -onvalue "0" -offvalue "1" -command {set bmask(32) "000000001000000"; write_socket b 32} -justify left -bg $colb
 pack .crewinp.cb12a -side top -in .crewinp.fma -anchor w -fill x -pady 1

 checkbutton .crewinp.cb13a -text "THRUSTERS 10&11 DISABLED" -variable b(32,8) -relief raised -borderwidth 2 -anchor w -font ${font11} -onvalue "0" -offvalue "1" -command {set bmask(32) "000000010000000"; write_socket b 32} -justify left -bg $colb
 pack .crewinp.cb13a -side top -in .crewinp.fma -anchor w -fill x -pady 1

 label .crewinp.l0b -text "RADAR:" -font ${font11b} -bg $colb
 pack  .crewinp.l0b -side top -in .crewinp.fmb -anchor w

 checkbutton .crewinp.cb1b -text "RR AUTO-POWER ON" -variable b(33,2) -relief raised -borderwidth 2 -anchor w -font ${font11}  -onvalue "0" -offvalue "1" -command {set bmask(33) "000000000000010"; write_socket b 33} -bg $colb
 pack .crewinp.cb1b -side top -in .crewinp.fmb -anchor w -fill x

 label .crewinp.l2b -text "IMU:" -font ${font11b} -bg $colb
 pack  .crewinp.l2b -side top -in .crewinp.fmb -anchor w -pady 1

 checkbutton .crewinp.cb21b -text "ISS TURN ON REQUESTED" -variable b(30,14) -relief raised -borderwidth 2 -anchor w -font ${font11} -command {set bmask(30) "010000000000000"; write_socket b 30} -onvalue 0 -offvalue 1 -justify left -bg $colb
 pack .crewinp.cb21b -side top -in .crewinp.fmb -anchor w -fill x -pady 1

 checkbutton .crewinp.cb4b -text "IMU CAGE COMMAND TO DRIVE\nIMU GIMBAL ANGLES TO 0" -variable b(30,11) -relief raised -borderwidth 2 -anchor w -font ${font11} -pady 2 -onvalue "0" -offvalue "1" -command {set bmask(30) "000010000000000"; write_socket b 30} -justify left -bg $colb
 pack .crewinp.cb4b -side top -in .crewinp.fmb -anchor w -fill x -pady 1

 checkbutton .crewinp.cb3b -text "DISPLAY INERTIAL DATA" -variable b(30,6) -relief raised -borderwidth 2 -anchor w -font ${font11} -onvalue "0" -offvalue "1" -command {set bmask(30) "000000000100000"; write_socket b 30} -bg $colb
 pack .crewinp.cb3b -side top -in .crewinp.fmb -anchor w -fill x

 label .crewinp.l5b -text "DAP/ATTITUDE MODE:" -font ${font11b} -bg $colb
 pack  .crewinp.l5b -side top -in .crewinp.fmb -anchor w -pady 1

 checkbutton .crewinp.cb51c -text "AGC HAS CONTROL OF LM\n(NOT AGS)" -variable b(30,10) -relief raised -borderwidth 2 -anchor w -font ${font11} -command {set bmask(30) "000001000000000"; write_socket b 30} -onvalue 0 -offvalue 1 -justify left -bg $colb
 pack .crewinp.cb51c -side top -in .crewinp.fmb -anchor w -fill x -pady 1

 radiobutton .crewinp.cb61b -text "DAP OFF" -variable DAPMODE -relief raised -borderwidth 2 -anchor w -font ${font11} -value "OFF" -command {set b(31,13) 1; set bmask(31) "001000000000000"; write_socket b 31; set b(31,14) 1; set bmask(31) "010000000000000"; write_socket b 31} -bg $colb

 radiobutton .crewinp.cb6b -text "ATTITUDE HOLD MODE ON" -variable DAPMODE -relief raised -borderwidth 2 -anchor w -font ${font11} -value "ATTHOLD" -command {set b(31,13) 0; set bmask(31) "001000000000000"; write_socket b 31; set b(31,14) 1; set bmask(31) "010000000000000"; write_socket b 31} -bg $colb

 pack .crewinp.cb61b .crewinp.cb6b -side top -in .crewinp.fmb -anchor w -fill x -pady 1

 radiobutton .crewinp.cb7b -text "AUTO STABILIZATION\nOF ATTITUDE ON" -variable DAPMODE -relief raised -borderwidth 2 -anchor w -font ${font11} -value "AUTO" -justify left -command {set b(31,14) 0; set bmask(31) "010000000000000"; write_socket b 31; set b(31,13) 1; set bmask(31) "001000000000000"; write_socket b 31} -bg $colb

 pack .crewinp.cb7b -side top -in .crewinp.fmb -anchor w -fill x -pady 1

 label .crewinp.l9b -text "AOT BUTTONS:" -font ${font11b} -bg $colb
 pack  .crewinp.l9b -side top -in .crewinp.fmb -anchor w -pady 1

 checkbutton .crewinp.cb10b -text "X-AXIS MARK" -variable b(16,3) -relief raised -borderwidth 2 -anchor w -font ${font11} -command {set bmask(16) "000000000000100"; write_socket b 16; after 200 {reset_crew_buttons}} -onvalue 1 -offvalue 0 -justify left -bg $colb
 pack .crewinp.cb10b -side top -in .crewinp.fmb -anchor w -fill x -pady 1

 checkbutton .crewinp.cb11b -text "Y-AXIS MARK" -variable b(16,4) -relief raised -borderwidth 2 -anchor w -font ${font11} -command {set bmask(16) "000000000001000"; write_socket b 16; after 200 {reset_crew_buttons}} -onvalue 1 -offvalue 0 -justify left -bg $colb
 pack .crewinp.cb11b -side top -in .crewinp.fmb -anchor w -fill x -pady 1

 checkbutton .crewinp.cb12b -text "MARK REJECT" -variable b(16,5) -relief raised -borderwidth 2 -anchor w -font ${font11} -command {set bmask(16) "000000000010000"; write_socket b 16; after 200 {reset_crew_buttons}} -onvalue 1 -offvalue 0 -justify left -bg $colb
 pack .crewinp.cb12b -side top -in .crewinp.fmb -anchor w -fill x -pady 1

 label .crewinp.l20b -text "DESCENT CONTROL:" -font ${font11b} -bg $colb
 pack  .crewinp.l20b -side top -in .crewinp.fmb -anchor w -pady 1

 checkbutton .crewinp.cb13b -text "DESCENT+" -variable b(16,6) -relief raised -borderwidth 2 -anchor w -font ${font11} -command {set bmask(16) "000000000100000"; write_socket b 16; after 200 {reset_crew_buttons}} -onvalue 1 -offvalue 0 -justify left -bg $colb
 pack .crewinp.cb13b -side top -in .crewinp.fmb -anchor w -fill x -pady 1

 checkbutton .crewinp.cb14b -text "DESCENT-" -variable b(16,7) -relief raised -borderwidth 2 -anchor w -font ${font11} -command {set bmask(16) "000000001000000"; write_socket b 16; after 200 {reset_crew_buttons}} -onvalue 1 -offvalue 0 -justify left -bg $colb
 pack .crewinp.cb14b -side top -in .crewinp.fmb -anchor w -fill x -pady 1

 label .crewinp.l1c -text "RHC/ACA:" -font ${font11b} -bg $colb
 pack  .crewinp.l1c -side top -in .crewinp.fmc -anchor w -pady 1

 frame .crewinp.fmc1 -bg $colb; frame .crewinp.fmc2 -bg $colb; frame .crewinp.fmc3 -bg $colb
 pack .crewinp.fmc1 .crewinp.fmc2 .crewinp.fmc3 -side top -in .crewinp.fmc -anchor w -pady 2

 scale .crewinp.roll -label "Roll" -from -57 -to 57 -length 130 -orient horizontal -variable RHCRoll -bg $colb -activebackground $colb -highlightbackground $colb -font ${font11b} -showvalue true -command {write_rhc ROLL}
 pack .crewinp.roll -side left -in .crewinp.fmc1 -anchor w 

 button .crewinp.neutral -text "DETENT" -command {write_rhc NEUTRAL 0} -font ${font11} -fg black -bg $colb
 pack .crewinp.neutral -side left -in .crewinp.fmc2 -anchor w

 scale .crewinp.pitch -label "Pitch" -from -57 -to 57 -length 130 -orient vertical -variable RHCPitch -bg $colb -activebackground $colb -highlightbackground $colb -font ${font11b} -showvalue true -command {write_rhc PITCH}
pack .crewinp.pitch -side left -in .crewinp.fmc2 -anchor e

 scale .crewinp.yaw -label "Yaw" -from 57 -to -57 -length 130 -orient horizontal -variable RHCYaw -bg $colb -activebackground $colb -highlightbackground $colb -font ${font11b} -showvalue true -command {write_rhc YAW}
 pack .crewinp.yaw -side left -in .crewinp.fmc3 -anchor w 

 label .crewinp.l10c -text "THC:" -font ${font11b} -bg $colb
 pack  .crewinp.l10c -side top -in .crewinp.fmc -anchor w -pady 1

 radiobutton .crewinp.rb10c -text "NEUTRAL" -variable THC -value "NEUTRAL" -font ${font11} -command {set b(31,7) 1; set b(31,8) 1; set b(31,9) 1; set b(31,10) 1; set b(31,11) 1 ; set b(31,12) 1; set bmask(31) "000111111000000"; write_socket b 31} -relief raised -bg $colb
 pack .crewinp.rb10c -side top -in .crewinp.fmc -anchor w -pady 1

 frame .crewinp.fmc4 -bg $colb; frame .crewinp.fmc5 -bg $colb; frame .crewinp.fmc6  -bg $colb
 pack .crewinp.fmc4 .crewinp.fmc5 .crewinp.fmc6 -side top -in .crewinp.fmc -anchor w -pady 2

 radiobutton .crewinp.rb11c -text " +X   " -variable THC -value "+PITCH" -font ${font11} -command {set b(31,7) 0; set b(31,8) 1; set b(31,9) 1; set b(31,10) 1; set b(31,11) 1 ; set b(31,12) 1; set bmask(31) "000111111000000"; write_socket b 31} -relief raised -bg $colb
 radiobutton .crewinp.rb12c -text " -X   " -variable THC -value "-PITCH" -font ${font11} -command {set b(31,7) 1; set b(31,8) 0; set b(31,9) 1; set b(31,10) 1; set b(31,11) 1 ; set b(31,12) 1; set bmask(31) "000111111000000"; write_socket b 31} -relief raised -bg $colb
 pack .crewinp.rb11c .crewinp.rb12c -side left -in .crewinp.fmc4 -anchor w 

 radiobutton .crewinp.rb13c -text " +Y   " -variable THC -value "+YAW" -font ${font11} -command {set b(31,7) 1; set b(31,8) 1; set b(31,9) 0; set b(31,10) 1; set b(31,11) 1 ; set b(31,12) 1; set bmask(31) "000111111000000"; write_socket b 31} -relief raised -bg $colb
 radiobutton .crewinp.rb14c -text " -Y   " -variable THC -value "-YAW" -font ${font11} -command {set b(31,7) 1; set b(31,8) 1; set b(31,9) 1; set b(31,10) 0; set b(31,11) 1 ; set b(31,12) 1; set bmask(31) "000111111000000"; write_socket b 31} -relief raised -bg $colb
 pack .crewinp.rb13c .crewinp.rb14c -side left -in .crewinp.fmc5 -anchor w 

 radiobutton .crewinp.rb15c -text " +Z   " -variable THC -value "+ROLL" -font ${font11} -command {set b(31,7) 1; set b(31,8) 1; set b(31,9) 1; set b(31,10) 1; set b(31,11) 0 ; set b(31,12) 1; set bmask(31) "000111111000000"; write_socket b 31} -relief raised -bg $colb
 radiobutton .crewinp.rb16c -text " -Z   " -variable THC -value "-ROLL" -font ${font11} -command {set b(31,7) 1; set b(31,8) 1; set b(31,9) 1; set b(31,10) 1; set b(31,11) 1 ; set b(31,12) 0; set bmask(31) "000111111000000"; write_socket b 31} -relief raised -bg $colb
 pack .crewinp.rb15c .crewinp.rb16c -side left -in .crewinp.fmc6 -anchor w 
}


# ********************************************************************************************
# **** Function:  Reset Crew Buttons                                                      ****
# ********************************************************************************************
proc reset_crew_buttons {} {
 global b bmask wdata

 if {$b(16,3) == 1} {set b(16,3) 0; set bmask(16) "000000000000100"; write_socket b 16}
 if {$b(16,4) == 1} {set b(16,4) 0; set bmask(16) "000000000001000"; write_socket b 16}
 if {$b(16,5) == 1} {set b(16,5) 0; set bmask(16) "000000000010000"; write_socket b 16}
 if {$b(16,6) == 1} {set b(16,6) 0; set bmask(16) "000000000100000"; write_socket b 16}
 if {$b(16,7) == 1} {set b(16,7) 0; set bmask(16) "000000001000000"; write_socket b 16}
 if {$b(32,14) == 0} {set b(32,14) 1; set bmask(32) "010000000000000"; write_socket b 32}
}


# ***********************************************************************************************
# **** Function: Reset RHC for Minimum Impulse Mode                                          ****
# ***********************************************************************************************
proc reset_rhc {} {
  global b bmask

  set b(31,1) 1; set b(31,2) 1; set b(31,3) 1; set b(31,4) 1; set b(31,5) 1; set b(31,6) 1
  set bmask(31) "000000000111111"
  write_socket b 31
}


# ***********************************************************************************************
# **** Function: Read RHC/ACA Slider positions and write them into the fictious AGC channels ****
# ***********************************************************************************************
proc write_rhc {par1 par2} {
 global b bmask wdata RHCRoll RHCPitch RHCYaw RHCImpFlag

 if {$par1 == "NEUTRAL"} {
   set RHCRoll 0; set RHCPitch 0; set RHCYaw 0;
   reset_rhc
   set b(31,15) 1
   set bmask(31) "100000000111111"
   set wdata(166) "000000000000000"
   set bmask(166) "111111111111111"
   set wdata(167) "000000000000000"
   set bmask(167) "111111111111111"
   set wdata(170) "000000000000000"
   set bmask(170) "111111111111111"
   write_socket b 31; write_socket w 166; write_socket w 167; write_socket w 170
 }

 # ---- Roll ----
 if {$par1 == "ROLL"} {
   if {$RHCRoll < 0} {
     if {$b(31,15) == 1} {set b(31,5) 1; set b(31,6) 0; after 100 {reset_rhc}}
     set b(31,15) 0
     set roll [expr $RHCRoll + 63]
     set prefix "111111111"
   } elseif {$RHCRoll > 0} {
     if {$b(31,15) == 1} {set b(31,5) 0; set b(31,6) 1; after 100 {reset_rhc}}
     set b(31,15) 0
     set roll $RHCRoll
     set prefix "000000000"
   } else {
     set roll 0
     set prefix "000000000"
   }
   set tmp [format %c $roll]
   binary scan $tmp B8 roll
   set roll $prefix[string range $roll 2 7]
   set bmask(31) "100000000110000"
   set wdata(170) $roll
   set bmask(170) "111111111111111"
   write_socket b 31; write_socket w 170
 }

 # ---- Pitch ----
 if {$par1 == "PITCH"} {
   if {$RHCPitch < 0} {
     if {$b(31,15) == 1} {set b(31,1) 1; set b(31,2) 0; after 100 {reset_rhc}}
     set b(31,15) 0
     set pitch [expr $RHCPitch + 63]
     set prefix "111111111"
   } elseif {$RHCPitch > 0} {
     if {$b(31,15) == 1} {set b(31,1) 0; set b(31,2) 1; after 100 {reset_rhc}}
     set b(31,15) 0
     set pitch $RHCPitch
     set prefix "000000000"
   } else {
     set pitch 0
     set prefix "000000000"
   }
   set tmp [format %c $pitch]
   binary scan $tmp B8 pitch
   set pitch $prefix[string range $pitch 2 7]
   set bmask(31) "100000000000011"
   set wdata(166) $pitch
   set bmask(166) "111111111111111"
   write_socket b 31; write_socket w 166
 }

 # ---- Yaw ----
 if {$par1 == "YAW"} {
   if {$RHCYaw < 0} {
     if {$b(31,15) == 1} {set b(31,3) 1; set b(31,4) 0; after 100 {reset_rhc}}
     set b(31,15) 0
     set yaw [expr $RHCYaw + 63]
     set prefix "111111111"
   } elseif {$RHCYaw > 0} {
     if {$b(31,15) == 1} {set b(31,3) 0; set b(31,4) 1; after 100 {reset_rhc}}
     set b(31,15) 0
     set yaw $RHCYaw
     set prefix "000000000"
   } else {
     set yaw 0
     set prefix "000000000"
   }
   set tmp [format %c $yaw]
   binary scan $tmp B8 yaw
   set yaw $prefix[string range $yaw 2 7]
   set bmask(31) "100000000001100"
   set wdata(167) $yaw
   set bmask(167) "111111111111111"
   write_socket b 31; write_socket w 167
 }

 # ---- Check for Out of Detend ----
 if {$RHCRoll == 0 && $RHCPitch == 0 && $RHCYaw == 0 && $b(31,15) == 0} {
   set b(31,15) 1
   set bmask(31) "100000000000000"
   write_socket b 31
 }
 #.text insert end "Out of Detent: $b(31,15)\n"; .text yview moveto 1
}

