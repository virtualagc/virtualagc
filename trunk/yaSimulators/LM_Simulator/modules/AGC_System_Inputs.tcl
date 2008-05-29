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
# **** Module:         AGC_System_Inputs.tcl                                              ****
# **** Main Program:   lm_system_simulator                                                ****
# **** Author:         Stephan Hotto                                                      ****
# **** Date/Loacation: 21.04.07/Germany                                                   ****
# **** Version:        v1.0                                                               ****
# ********************************************************************************************

# ********************************************************************************************
# **** Function:  Create AGC System Inputs GUI                                            ****
# ********************************************************************************************
proc create_sysinp {} {
 global bo font1 font11 font11b font2 font3 colb Operating_System
 global IMUX_ANGLE IMUY_ANGLE IMUZ_ANGLE

 if {[winfo exists .sysinp] == 1} {destroy .sysinp}

 toplevel .sysinp -background $colb
 wm title .sysinp "AGC LM System Inputs"
 if {$Operating_System == "linux"} {
   wm geometry .sysinp +110+110; wm geometry .sysinp 370x320; wm minsize  .sysinp 370 320
 } else {
   wm geometry .sysinp +110+110; wm geometry .sysinp 420x350; wm minsize  .sysinp 420 350
 }
 wm iconname .sysinp "AGC LM System Inputs"

 frame .sysinp.fma -bg $colb; frame .sysinp.fmb -bg $colb; frame .sysinp.fmc -bg $colb; frame .sysinp.fmd -bg $colb;

 pack .sysinp.fma .sysinp.fmb .sysinp.fmc .sysinp.fmd -side left -anchor n -pady 1 -padx 15

 # --------------------- Checkbutton as Signal Indicator --------------------------
 # --------------------- 1st column -----------------------------------------------
 label .sysinp.l0a -text "COMMON:" -font ${font11b} -bg $colb
 pack  .sysinp.l0a -side top -in .sysinp.fma -anchor w

 checkbutton .sysinp.cb1c -text "OVER TEMPERATURE OF\nSTABLE MEMBER" -variable b(30,15) -relief raised -borderwidth 2 -anchor w -font ${font11} -command {set bmask(30) "100000000000000"; write_socket b 30} -justify left -bg $colb
 pack .sysinp.cb1c -side top -in .sysinp.fma -anchor w -fill x -pady 1

 checkbutton .sysinp.cb2c -text "LGC OSCILLATOR STOPPED" -variable b(33,15) -relief raised -borderwidth 2 -anchor w -font ${font11} -command {set bmask(33) "100000000000000"; write_socket b 33} -onvalue 0 -offvalue 1 -bg $colb
 pack .sysinp.cb2c -side top -in .sysinp.fma -anchor w -fill x -pady 1

 checkbutton .sysinp.cb3c -text "BLOCK UPLINK INPUT" -variable b(33,10) -relief raised -borderwidth 2 -anchor w -font ${font11} -command {set bmask(33) "000001000000000"; write_socket b 33} -onvalue 0 -offvalue 1 -bg $colb
 pack .sysinp.cb3c -side top -in .sysinp.fma -anchor w -fill x -pady 1

 checkbutton .sysinp.cb4c -text "UPLINK TOO FAST" -variable b(33,11) -relief raised -borderwidth 2 -anchor w -font ${font11}  -command {set bmask(33) "000010000000000"; write_socket b 33} -onvalue 0 -offvalue 1 -bg $colb
 pack .sysinp.cb4c -side top -in .sysinp.fma -anchor w -fill x -pady 1

 checkbutton .sysinp.cb5c -text "DOWNLINK TOO FAST" -variable b(33,12) -relief raised -borderwidth 2 -anchor w -font ${font11}  -command {set bmask(33) "000100000000000"; write_socket b 33} -onvalue 0 -offvalue 1 -bg $colb
 pack .sysinp.cb5c -side top -in .sysinp.fma -anchor w -fill x -pady 1

 checkbutton .sysinp.cb7c -text "WARNING OF REPEATED\nALARMS" -variable b(33,14) -relief raised -borderwidth 2 -anchor w -font ${font11} -command {set bmask(33) "010000000000000"; write_socket b 33} -onvalue 0 -offvalue 1 -justify left -bg $colb
 pack .sysinp.cb7c -side top -in .sysinp.fma -anchor w -fill x -pady 1

 label .sysinp.l10a -text "IMU:" -font ${font11b} -bg $colb
 pack  .sysinp.l10a -side top -in .sysinp.fma -anchor w -pady 1

 checkbutton .sysinp.cb12c -text "IMU OPERATE WITH\nNO MALFUNCTION" -variable b(30,9) -relief raised -borderwidth 2 -anchor w -font ${font11} -onvalue "0" -offvalue "1" -command {set bmask(30) "000000100000000"; write_socket b 30} -justify left -bg $colb
 pack .sysinp.cb12c -side top -in .sysinp.fma -anchor w -fill x -pady 1

 checkbutton .sysinp.cb14c -text "IMU CDU FAIL" -variable b(30,12) -relief raised -borderwidth 2 -anchor w -font ${font11}  -onvalue "0" -offvalue "1" -command {set bmask(30) "000100000000000"; write_socket b 30} -bg $colb
 pack .sysinp.cb14c -side top -in .sysinp.fma -anchor w -fill x -pady 1

 checkbutton .sysinp.cb15c -text "IMU FAIL" -variable b(30,13) -relief raised -borderwidth 2 -anchor w -font ${font11} -onvalue "0" -offvalue "1" -command {set bmask(30) "001000000000000"; write_socket b 30} -bg $colb
 pack .sysinp.cb15c -side top -in .sysinp.fma -anchor w -fill x -pady 1

  checkbutton .sysinp.cb16c -text "PIPA FAIL" -variable b(33,13) -relief raised -borderwidth 2 -anchor w -font ${font11}  -command {set bmask(33) "001000000000000"; write_socket b 33} -onvalue 0 -offvalue 1 -bg $colb
 pack .sysinp.cb16c -side top -in .sysinp.fma -anchor w -fill x -pady 1

# --------------------- 2nd column -----------------------------------------------
 label .sysinp.l0b -text "RADAR:" -font ${font11b} -bg $colb
 pack  .sysinp.l0b -side top -in .sysinp.fmb -anchor w

 checkbutton .sysinp.cb0b -text "RR CDU FAIL" -variable b(30,7) -relief raised -borderwidth 2 -anchor w -font ${font11}  -onvalue "0" -offvalue "1" -command {set bmask(30) "000000001000000"; write_socket b 30} -bg $colb
 pack .sysinp.cb0b -side top -in .sysinp.fmb -anchor w -fill x -pady 1

 checkbutton .sysinp.cb2b -text "RR RANGE LOW SCALE" -variable b(33,3) -relief raised -borderwidth 2 -anchor w -font ${font11}  -onvalue "0" -offvalue "1" -command {set bmask(33) "000000000000100"; write_socket b 33} -bg $colb
 pack .sysinp.cb2b -side top -in .sysinp.fmb -anchor w -fill x -pady 1

 checkbutton .sysinp.cb3b -text "RR DATA GOOD" -variable b(33,4) -relief raised -borderwidth 2 -anchor w -font ${font11}  -onvalue "0" -offvalue "1" -command {set bmask(33) "000000000001000"; write_socket b 33} -bg $colb
 pack .sysinp.cb3b -side top -in .sysinp.fmb -anchor w -fill x -pady 1

 checkbutton .sysinp.cb4b -text "LR RANGE DATA GOOD" -variable b(33,5) -relief raised -borderwidth 2 -anchor w -font ${font11}  -onvalue "0" -offvalue "1" -command {set bmask(33) "000000000010000"; write_socket b 33} -bg $colb
 pack .sysinp.cb4b -side top -in .sysinp.fmb -anchor w -fill x -pady 1

 checkbutton .sysinp.cb5b -text "LR VELOCITY DATA GOOD" -variable b(33,8) -relief raised -borderwidth 2 -anchor w -font ${font11} -onvalue "0" -offvalue "1" -command {set bmask(33) "000000010000000"; write_socket b 33} -bg $colb
 pack .sysinp.cb5b -side top -in .sysinp.fmb -anchor w -fill x -pady 1

 checkbutton .sysinp.cb6b -text "LR RANGE LOW SCALE" -variable b(33,9) -relief raised -borderwidth 2 -anchor w -font ${font11}  -onvalue "0" -offvalue "1" -command {set bmask(33) "000000100000000"; write_socket b 33} -bg $colb
 pack .sysinp.cb6b -side top -in .sysinp.fmb -anchor w -fill x -pady 1

 checkbutton .sysinp.cb7b -text "LR POS1" -variable b(33,6) -relief raised -borderwidth 2 -anchor w -font ${font11} -onvalue "0" -offvalue "1" -command {set bmask(33) "000000000100000"; write_socket b 33} -bg $colb
 pack .sysinp.cb7b -side top -in .sysinp.fmb -anchor w -fill x -pady 1

 checkbutton .sysinp.cb8b -text "LR POS2" -variable b(33,7) -relief raised -borderwidth 2 -anchor w -font ${font11} -onvalue "0" -offvalue "1" -command {set bmask(33) "000000001000000"; write_socket b 33} -bg $colb
 pack .sysinp.cb8b -side top -in .sysinp.fmb -anchor w -fill x -pady 1
}
