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
# **** Module:         AGC_IMU.tcl                                                        ****
# **** Main Program:   lm_simulator                                                       ****
# **** Author:         Stephan Hotto                                                      ****
# **** Date/Location:  21.04.07/Germany                                                   ****
# **** Version:        v1.0                                                               ****
# ********************************************************************************************

# ********************************************************************************************
# **** Function:  Create AGC IMU GUI                                                      ****
# ********************************************************************************************
proc create_imugui {} {
 global bo font0 font1 font2 font3 font4 colb colb2 colb3 widgtM Operating_System FDAI_Mode
 global 2PI PI
 global offsetx offsety V font11 font11b

 if {[winfo exists .imu] == 1} {destroy .imu}

 toplevel .imu -background $colb2
 wm title .imu "FDAI / IMU"
 if {$Operating_System == "linux"} {
   wm geometry .imu +405+460; wm geometry .imu 450x465; wm minsize  .imu 450 465
 } else {
   wm geometry .imu +410+500; wm geometry .imu 490x465; wm minsize  .imu 490 465
 }
 wm iconname .imu "FDAI/IMU"

 # ---- 2 Vertical Frames ----
 frame .imu.fmp1 -bg $colb2; frame .imu.fmp2 -bg $colb2; frame .imu.fmp3 -bg $colb2
 pack .imu.fmp1 .imu.fmp2 -side top
 
 # ---- 2 Horizontal Frames ----
 frame .imu.fms1 -bg $colb2; frame .imu.fms2
 pack .imu.fms1 .imu.fms2 -in .imu.fmp1 -side left
 
 frame .imu.fma -bg $colb2; frame .imu.fmb -bg $colb2; ; frame .imu.fmb2 -bg $colb2; frame .imu.fmc -bg $colb2
 frame .imu.fmd -bg $colb2; frame .imu.fme -bg $colb2
 pack .imu.fmb .imu.fmb2 .imu.fmc .imu.fmd .imu.fme -in .imu.fmp2 -side top -anchor w -padx 1

 # ----
 checkbutton .imu.cb1 -text "Ball On/Off" -variable FDAI_Mode -relief raised -borderwidth 2 -anchor w -font ${font11} -onvalue "1" -offvalue "0" -justify left -bg $colb
 pack .imu.cb1 -side top -in .imu.fms2 -anchor w -fill x -pady 1
 
 # -------------------- Rotation FDAI - Scale Canvas ----------------------------------
 canvas .imu.c2 -width 350 -height 360 -relief flat -bg $colb3 -borderwidth 0 -selectborderwidth 0 -insertborderwidth 0 -highlightbackground $colb2 -highlightcolor $colb3
 pack  .imu.c2 -side top -in .imu.fms1

 label .imu.l1b -text "IMU   Angle         Velocity      FDAI    Angle   Omega     Attitude" -font ${font11b} -bg $colb2 
 label .imu.l2b -text "Axes  \[Deg\]     \[m/s\]    \[ft/s\]           \[Deg\]   \[Deg/s\]   Error" -font ${font11b} -bg $colb2 
 pack  .imu.l1b -side top -in .imu.fmb
 pack  .imu.l2b -side top -in .imu.fmb2

 label .imu.l1c -text "X:  " -font ${font11b} -bg $colb2
 label .imu.l2c -text "---.--" -font ${font11} -bg $colb2
 label .imu.l3c -text " " -font ${font11} -bg $colb2
 label .imu.l4c -text "----.-" -font ${font11} -bg $colb2
 label .imu.l5c -text " " -font ${font11} -bg $colb2
 label .imu.l6c -text "----.-" -font ${font11} -bg $colb2
 label .imu.l7c -text "  YAW:  " -font ${font11b} -bg $colb2
 label .imu.l81c -text "---.--" -font ${font11} -bg $colb2
 label .imu.l8c -text "---.--" -font ${font11} -bg $colb2
 label .imu.l9c -text "  " -font ${font11} -bg $colb2
 label .imu.l10c -text "---" -font ${font11} -bg $colb2
 pack  .imu.l1c .imu.l2c .imu.l3c .imu.l4c .imu.l5c .imu.l6c .imu.l7c .imu.l81c .imu.l8c .imu.l9c .imu.l10c -side left -in .imu.fmc

 label .imu.l1d -text "Y:  " -font ${font11b} -bg $colb2
 label .imu.l2d -text "---.--" -font ${font11} -bg $colb2
 label .imu.l3d -text " " -font ${font11} -bg $colb2
 label .imu.l4d -text "----.-" -font ${font11} -bg $colb2
 label .imu.l5d -text " " -font ${font11} -bg $colb2
 label .imu.l6d -text "----.-" -font ${font11} -bg $colb2
 label .imu.l7d -text "  PITCH:" -font ${font11b} -bg $colb2
 label .imu.l81d -text "---.--" -font ${font11} -bg $colb2
 label .imu.l8d -text "---.--" -font ${font11} -bg $colb2
 label .imu.l9d -text "  " -font ${font11} -bg $colb2
 label .imu.l10d -text "---" -font ${font11} -bg $colb2
 pack  .imu.l1d .imu.l2d .imu.l3d .imu.l4d .imu.l5d .imu.l6d .imu.l7d .imu.l81d .imu.l8d .imu.l9d .imu.l10d -side left -in .imu.fmd

 label .imu.l1e -text "Z:  " -font ${font11b} -bg $colb2
 label .imu.l2e -text "---.--" -font ${font11} -bg $colb2
 label .imu.l3e -text " " -font ${font11} -bg $colb2
 label .imu.l4e -text "----.-" -font ${font11} -bg $colb2
 label .imu.l5e -text " " -font ${font11} -bg $colb2
 label .imu.l6e -text "----.-" -font ${font11} -bg $colb2
 label .imu.l7e -text "  ROLL: " -font ${font11b} -bg $colb2
 label .imu.l81e -text "---.--" -font ${font11} -bg $colb2
 label .imu.l8e -text "---.--" -font ${font11} -bg $colb2
 label .imu.l9e -text "  " -font ${font11} -bg $colb2
 label .imu.l10e -text "---" -font ${font11} -bg $colb2
 pack  .imu.l1e .imu.l2e .imu.l3e .imu.l4e .imu.l5e .imu.l6e .imu.l7e .imu.l81e .imu.l8e .imu.l9e .imu.l10e -side left -in .imu.fme

 # ------------------- Create Pitch Scale ---------------------------------------------
 for {set i -270} {$i <= 270} {set i [expr $i + 30]} {
   if {$i >= -180 && $i <= 0 || $i >= 180 && $i <= 360} {set col "black"} else {set col "white"}
   set widgtM(PITCH_$i) [.imu.c2 create line 0 0 0 0 -fill $col -width 1]
   if {$i < 0} {set j [expr $i + 360]} else {set j $i}
   set widgtM(PITCH_TXT_$i) [.imu.c2 create text 0 0 -text $j -anchor s -font $font0 -fill $col]
 }

 # -------------------- Create Z-Axis ---------------------
 set widgtM(zAxisLM) [.imu.c2 create line 0 0 0 0 -fill blue]

 set j 0
 for {set i -270} {$i <= 270} {set i [expr $i + 30]} {
    set widgtM(zAxis_$i) [.imu.c2 create line 0 0 0 0 -fill blue]
    if {$i < 0} {set j [expr $i + 360]} else {set j $i}
    set widgtM(zAxis_TXT_$i) [.imu.c2 create text 0 0 -text $j -anchor n -font $font0 -fill blue]
 }

 # -------------------- Create Roll Indicator ---------------
 set widgtM(RollMarker) [.imu.c2 create line 0 0 0 0 -fill black -arrow last -arrowshape {18 18 7}]

 # -------------------- Create Yaw Error Needle -------------
 set widgtM(YawErrorNeedle) [.imu.c2 create line 0 0 0 0 -fill orange]

 # -------------------- Create Pitch Error Needle -----------
 set widgtM(PitchErrorNeedle) [.imu.c2 create line 0 0 0 0 -fill orange]

 # -------------------- Create Roll Error Needle ------------
 set widgtM(RollErrorNeedle) [.imu.c2 create line 0 0 0 0 -fill orange]

 # -------------------- Create Circle, Scaling ---------------------
 .imu.c2 create oval [expr $offsetx-190] [expr $offsety-190] [expr $offsetx+190] [expr $offsety+190] -outline gray80 -width 180

 # ---- Create Red Gimbal Lock Area ----
 set mag 1
 for {set i 70} {$i < 110} {set i [expr $i + 0.5]} {
   set j [expr $i/180.0*$PI]
   set xp1 [expr $offsetx + 100 * sin($j+$PI)]
   set xp2 [expr $offsetx + $mag * 110 * sin($j+$PI)]
   set yp1 [expr $offsety + 100 * cos($j+$PI)]
   set yp2 [expr $offsety + $mag * 110 * cos($j+$PI)]
   .imu.c2 create line $xp1 $yp1 $xp2 $yp2 -fill red -width 2
 }

 for {set i 250} {$i < 290} {set i [expr $i + 0.5]} {
   set j [expr $i/180.0*$PI]
   set xp1 [expr $offsetx + 100 * sin($j+$PI)]
   set xp2 [expr $offsetx + $mag * 110 * sin($j+$PI)]
   set yp1 [expr $offsety + 100 * cos($j+$PI)]
   set yp2 [expr $offsety + $mag * 110 * cos($j+$PI)]
   .imu.c2 create line $xp1 $yp1 $xp2 $yp2 -fill red -width 2
 }

 # ---- Create Roll Scale ----
 for {set i 0} {$i < 360} {set i [expr $i + 10]} {
   if {$i==0 || $i==30 || $i==60 || $i==90 || $i==120 || $i==180 || $i==210 || $i==240 || $i==270 || $i==300 || $i==330 || $i==360 || $i==30} {set mag 1.05} else {set mag 1}
   set j [expr $i/180.0*$PI]
   set xp1 [expr $offsetx + 100 * sin($j+$PI)]
   set xp2 [expr $offsetx + $mag * 110 * sin($j+$PI)]
   set yp1 [expr $offsety + 100 * cos($j+$PI)]
   set yp2 [expr $offsety + $mag * 110 * cos($j+$PI)]
   .imu.c2 create line $xp1 $yp1 $xp2 $yp2 -fill white -width 2
 }

 .imu.c2 create oval [expr $offsetx-100] [expr $offsety-100] [expr $offsetx+100] [expr $offsety+100] -outline black -width 4

 # ------------------- Create Cross Mark -------------------------------
 .imu.c2 create line [expr $offsetx-10] [expr $offsety] [expr $offsetx+10] [expr $offsety] -fill white -width 1
 .imu.c2 create line [expr $offsetx] [expr $offsety-10] [expr $offsetx] [expr $offsety+10] -fill white -width 1

 # ---- Create Yaw Rate Scale and Pointer ----
 for {set i -5} {$i <= 5} {incr i 1} {
   .imu.c2 create line [expr $offsetx + 10.0 * $i] 310 [expr $offsetx + 10.0 * $i] 315 -fill white
 }
 set widgtM(YawRateMarker) [.imu.c2 create line 0 0 0 0 -fill black -arrow last -arrowshape {11 11 5}]
 .imu.c2 create text $offsetx 310 -text "0" -anchor s -font $font11 -fill white
 .imu.c2 create text $offsetx 340 -text "YAW RATE" -anchor s -font $font11b -fill white

 # ---- Create Roll Rate Scale and Pointer ----
 for {set i -5} {$i <= 5} {incr i 1} {
   .imu.c2 create line [expr $offsetx + 10.0 * $i] 45 [expr $offsetx + 10.0 * $i] 50 -fill white
 }
 set widgtM(RollRateMarker) [.imu.c2 create line 0 0 0 0 -fill black -arrow last -arrowshape {11 11 5}]
 .imu.c2 create text $offsetx 51 -text "0" -anchor n -font $font11 -fill white
 .imu.c2 create text $offsetx 30 -text "ROLL RATE" -anchor s -font $font11b -fill white

 # ---- Create Pitch Rate Scale and Pointer ----
 for {set i -5} {$i <= 5} {incr i 1} {
   .imu.c2 create line 280 [expr $offsety + 10.0 * $i] 285 [expr $offsety + 10.0 * $i] -fill white
 }
 set widgtM(PitchRateMarker) [.imu.c2 create line 0 0 0 0 -fill black -arrow last -arrowshape {11 11 5}]
 .imu.c2 create text [expr $offsetx + 128] $offsety -text "0" -anchor e -font $font11 -fill white
 .imu.c2 create text [expr $offsetx + 155] [expr $offsety - 30] -text "P" -anchor s -font $font11b -fill white
 .imu.c2 create text [expr $offsetx + 155] [expr $offsety - 22] -text "I" -anchor s -font $font11b -fill white
 .imu.c2 create text [expr $offsetx + 155] [expr $offsety - 14] -text "T" -anchor s -font $font11b -fill white
 .imu.c2 create text [expr $offsetx + 155] [expr $offsety - 6] -text "C" -anchor s -font $font11b -fill white
 .imu.c2 create text [expr $offsetx + 155] [expr $offsety + 2] -text "H" -anchor s -font $font11b -fill white

 .imu.c2 create text [expr $offsetx + 155] [expr $offsety + 18] -text "R" -anchor s -font $font11b -fill white
 .imu.c2 create text [expr $offsetx + 155] [expr $offsety + 26] -text "A" -anchor s -font $font11b -fill white
 .imu.c2 create text [expr $offsetx + 155] [expr $offsety + 34] -text "T" -anchor s -font $font11b -fill white
 .imu.c2 create text [expr $offsetx + 155] [expr $offsety + 42] -text "E" -anchor s -font $font11b -fill white

 # ---- GIMBAL LOCK Flag ----
 set widgtM(gimbalLock) [.imu.c2 create text $offsetx $offsety -text "" -anchor s -font $font4 -fill orange]

 # -------- Set Marker to current Angles ---------------
 # move_fdai_marker
}


# *********************************************************************************************
# **** Function: Move FDAI Marker                                                          ****
# *********************************************************************************************
proc move_fdai_marker {} {
 global widgtM offsetx offsety V FDAI_Mode
 global IMUX_ANGLE IMUY_ANGLE IMUZ_ANGLE PI 2PI
 global xVelocity yVelocity zVelocity MeterToFeet gimbalLock
 global DEG_TO_RAD RAD_TO_DEG Omega_Roll Omega_Pitch Omega_Yaw error_x error_y error_z NEEDLE_SCALE

 if {[winfo exists .imu] != 1} {return}
 
 # ---- If Gimbal Lock then show it on the FDAI ----
 if {$gimbalLock == 1} {
   .imu.c2 itemconfigure $widgtM(gimbalLock) -text "GIMBAL LOCK"
   return
 } else {
   .imu.c2 itemconfigure $widgtM(gimbalLock) -text ""
 }

 # ---- Transform from stable member to FDAI display ----
 set OGA [expr $IMUX_ANGLE * $DEG_TO_RAD]
 set IGA [expr $IMUY_ANGLE * $DEG_TO_RAD]
 set MGA [expr $IMUZ_ANGLE * $DEG_TO_RAD]

 set sinOG [expr sin($OGA)]
 set sinIG [expr sin($IGA)]
 set sinMG [expr sin($MGA)]
 set cosOG [expr cos($OGA)]
 set cosIG [expr cos($IGA)]
 set cosMG [expr cos($MGA)]
 
 # ---- Extract Attitude Euler angles out of the rotation matrix Stable Member into Navigation Base ----
 #set t11 [expr $cosIG*$cosMG]
 set t12 $sinMG
 #set t13 [expr -1*$sinIG*$cosMG]
 #set t21 [expr -1*$cosIG*$sinMG*$cosOG+$sinIG*$sinOG]
 set t22 [expr $cosMG*$cosOG]
 #set t23 [expr $sinIG*$sinMG*$cosOG+$cosIG*$sinOG]
 set t31 [expr $cosIG*$sinMG*$sinOG+$sinIG*$cosOG]
 set t32 [expr -1*$cosMG*$sinOG]
 set t33 [expr -1*$sinIG*$sinMG*$sinOG+$cosIG*$cosOG]
 
 set ROLL [expr atan2($t12,$t22)];
 if {$ROLL < -$2PI} {set ROLL [expr $ROLL + $2PI]}
 if {$ROLL >= $2PI} {set ROLL [expr $ROLL - $2PI]}
 
 set PITCH [expr atan2($t31,$t33)]
 if {$PITCH < -$2PI} {set PITCH [expr $PITCH + $2PI]}
 if {$PITCH >= $2PI} {set PITCH [expr $PITCH - $2PI]}

 set YAW [expr asin($t32)]
 if {$YAW < -$2PI} {set YAW [expr $YAW + $2PI]}
 if {$YAW >= $2PI} {set YAW [expr $YAW - $2PI]}
 
 # ---- Calculate FDAI Angels ----
 set FDAIZ_RAD $ROLL
 set SIN_Z [expr sin(-1*$FDAIZ_RAD)]
 set COS_Z [expr cos(-1*$FDAIZ_RAD)]
 
 set FDAIX_ANGLE [expr -1*$YAW * $RAD_TO_DEG]
 set FDAIY_ANGLE [expr $PITCH * $RAD_TO_DEG]
 set FDAIZ_ANGLE [expr $ROLL * $RAD_TO_DEG]
 
 # --- Prepare for FDAI Numerical Display ----
 if {$FDAIX_ANGLE > 0} {set fdaix [expr -$FDAIX_ANGLE + 360.0]} else {set fdaix [expr abs($FDAIX_ANGLE)]}
 if {$FDAIY_ANGLE < 0} {set fdaiy [expr $FDAIY_ANGLE + 360.0]} else {set fdaiy $FDAIY_ANGLE}
 if {$FDAIZ_ANGLE < 0} {set fdaiz [expr $FDAIZ_ANGLE + 360.0]} else {set fdaiz $FDAIZ_ANGLE} 

 .imu.l2c configure -text [format "%6.2f" $IMUX_ANGLE]
 .imu.l2d configure -text [format "%6.2f" $IMUY_ANGLE]
 .imu.l2e configure -text [format "%6.2f" $IMUZ_ANGLE]

 .imu.l4c configure -text [format "%7.1f" $xVelocity]
 .imu.l4d configure -text [format "%7.1f" $yVelocity]
 .imu.l4e configure -text [format "%7.1f" $zVelocity]

 .imu.l6c configure -text [format "%7.1f" [expr $xVelocity*$MeterToFeet]]
 .imu.l6d configure -text [format "%7.1f" [expr $yVelocity*$MeterToFeet]]
 .imu.l6e configure -text [format "%7.1f" [expr $zVelocity*$MeterToFeet]]

 .imu.l81c configure -text [format "%7.2f" $fdaix]
 .imu.l81d configure -text [format "%7.2f" $fdaiy]
 .imu.l81e configure -text [format "%7.2f" $fdaiz]
 
 .imu.l8c configure -text [format "%8.2f" $Omega_Yaw]
 .imu.l8d configure -text [format "%8.2f" $Omega_Pitch]
 .imu.l8e configure -text [format "%8.2f" $Omega_Roll]

 .imu.l10c configure -text [format "%4d" $error_x]
 .imu.l10d configure -text [format "%4d" $error_y]
 .imu.l10e configure -text [format "%4d" $error_z]

 # ---- Decide whether the FDAI shows the 8-Ball or just numbers ----
 if {$FDAI_Mode == 0} {return}

 # ------------------- Move Yaw Rate Marker ----------------------------------------
 if {$Omega_Yaw > 5.0} {set temp2 5.0} elseif {$Omega_Yaw < -5.0} {set temp2 -5.0} else {set temp2 $Omega_Yaw}
 set xp1 [expr $offsetx - 10.0 * $temp2]
 .imu.c2 coords $widgtM(YawRateMarker) $xp1 320 $xp1 316

 # ------------------- Move Pitch Rate Marker ----------------------------------------
 if {$Omega_Pitch > 5.0} {set temp2 5.0} elseif {$Omega_Pitch < -5.0} {set temp2 -5.0} else {set temp2 $Omega_Pitch}
 set yp1 [expr $offsety - 10.0 * $temp2]
 .imu.c2 coords $widgtM(PitchRateMarker) 290 $yp1 287 $yp1

 # ------------------- Move Roll Rate Marker ----------------------------------------
 if {$Omega_Roll > 5.0} {set temp2 5.0} elseif {$Omega_Roll < -5.0} {set temp2 -5.0} else {set temp2 $Omega_Roll}
 set xp1 [expr $offsetx + 10.0 * $temp2]
 .imu.c2 coords $widgtM(RollRateMarker) $xp1 40 $xp1 43

 # ------------------- Move Yaw Error Needle ---------------------------------------
 .imu.c2 coords $widgtM(YawErrorNeedle) [expr $offsetx + $error_x * $NEEDLE_SCALE] [expr $offsety + 10] [expr $offsetx + $error_x * $NEEDLE_SCALE] [expr $offsety + 100]

 # ------------------- Move Pitch Error Needle ---------------------------------------
 .imu.c2 coords $widgtM(PitchErrorNeedle) [expr $offsetx + 10] [expr $offsety + $error_y * $NEEDLE_SCALE] [expr $offsetx + 100] [expr $offsety + $error_y * $NEEDLE_SCALE] 

 # ------------------- Move Roll Error Needle ---------------------------------------
 .imu.c2 coords $widgtM(RollErrorNeedle) [expr $offsetx - $error_z * $NEEDLE_SCALE] [expr $offsety - 10] [expr $offsetx - $error_z * $NEEDLE_SCALE] [expr $offsety - 100]

 # ------------------- Rotate Roll Marker (LM-Z-Axis) ------------------------------
 set xp1 [expr $offsetx + 90 * sin($FDAIZ_RAD+$PI)]
 set xp2 [expr $offsetx + 95 * sin($FDAIZ_RAD+$PI)]
 set yp1 [expr $offsety + 90 * cos($FDAIZ_RAD+$PI)]
 set yp2 [expr $offsety + 95 * cos($FDAIZ_RAD+$PI)]
 .imu.c2 coords $widgtM(RollMarker) $xp1 $yp1 $xp2 $yp2

 # ------------------- Move Pitch Scale (LM-Y-Axis) ---------------------------------------------
 if {$FDAIY_ANGLE > 180} {set tmpYAngle [expr $FDAIY_ANGLE - 360]} else {set tmpYAngle $FDAIY_ANGLE}
 for {set i -270} {$i <= 270} {set i [expr $i + 30]} {
   set xp1 -50
   set xp2 50
   set yp1 [expr -$i + $tmpYAngle]
   set xpt 0
   set ypt $yp1

   # ------------------- Rotate Pitch Scale along the LM-Z-Axis ---------------------------------
   set xpt_r [expr $xpt * $COS_Z - $yp1 * $SIN_Z]
   set ypt_r [expr $xpt * $SIN_Z + $ypt * $COS_Z]

   set xp1_r [expr $xp1 * $COS_Z - $yp1 * $SIN_Z]
   set yp1_r [expr $xp1 * $SIN_Z + $yp1 * $COS_Z]

   set xp2_r [expr $xp2 * $COS_Z - $yp1 * $SIN_Z]
   set yp2_r [expr $xp2 * $SIN_Z + $yp1 * $COS_Z]

   # ------------------- Translate to the offset ---------------------------------------
   set xpt_r [expr $offsetx + $xpt_r]
   set ypt_r [expr $offsety + $ypt_r]
   set xp1_r [expr $offsetx + $xp1_r]
   set yp1_r [expr $offsety + $yp1_r]
   set xp2_r [expr $offsetx + $xp2_r]
   set yp2_r [expr $offsety + $yp2_r]

   # ------------------- Draw Pitch Marks ---------------------------------------------  
  .imu.c2 coords $widgtM(PITCH_TXT_$i) $xpt_r $ypt_r
  .imu.c2 coords $widgtM(PITCH_$i) $xp1_r $yp1_r $xp2_r $yp2_r
 }

 # -------------------- Move YAW-Axis (LM-X-Axis) ---------------------
 if {$FDAIX_ANGLE > 180} {set tmpXAngle [expr $FDAIX_ANGLE - 360]} else {set tmpXAngle $FDAIX_ANGLE}
 set xpLM1 [expr -280 + $tmpXAngle]
 set ypLM1 0
 set xpLM2 [expr 280 + $tmpXAngle]
 set ypLM2 0

 set xpLM1_r [expr $xpLM1 * $COS_Z - $ypLM1 * $SIN_Z]
 set ypLM1_r [expr $xpLM1 * $SIN_Z + $ypLM1 * $COS_Z]
 set xpLM2_r [expr $xpLM2 * $COS_Z - $ypLM2 * $SIN_Z]
 set ypLM2_r [expr $xpLM2 * $SIN_Z + $ypLM2 * $COS_Z]

 set xpLM1_r [expr $offsetx + $xpLM1_r]
 set ypLM1_r [expr $offsety + $ypLM1_r]
 set xpLM2_r [expr $offsetx + $xpLM2_r]
 set ypLM2_r [expr $offsety + $ypLM2_r]

 .imu.c2 coords $widgtM(zAxisLM) $xpLM1_r $ypLM1_r $xpLM2_r $ypLM2_r

 for {set i -270} {$i <= 270} {set i [expr $i + 30]} {
    set xp1 [expr $i + $tmpXAngle]
    set yp1 -2
    set xp2 [expr $i + $tmpXAngle]
    set yp2 3
    set xpt [expr $i + $tmpXAngle]
    set ypt 10

    set xp1_r [expr $xp1 * $COS_Z - $yp1 * $SIN_Z]
    set yp1_r [expr $xp1 * $SIN_Z + $yp1 * $COS_Z]
    set xp2_r [expr $xp2 * $COS_Z - $yp2 * $SIN_Z]
    set yp2_r [expr $xp2 * $SIN_Z + $yp2 * $COS_Z]
    set xpt_r [expr $xpt * $COS_Z - $ypt * $SIN_Z]
    set ypt_r [expr $xpt * $SIN_Z + $ypt * $COS_Z]

    # ------------------- Translate to the offset ---------------------------------------
    set xp1_r [expr $offsetx + $xp1_r]
    set yp1_r [expr $offsety + $yp1_r]
    set xp2_r [expr $offsetx + $xp2_r]
    set yp2_r [expr $offsety + $yp2_r]
    set xpt_r [expr $offsetx + $xpt_r]
    set ypt_r [expr $offsety + $ypt_r]

    .imu.c2 coords $widgtM(zAxis_$i) $xp1_r $yp1_r $xp2_r $yp2_r
    .imu.c2 coords $widgtM(zAxis_TXT_$i) $xpt_r $ypt_r
 }
}


# *********************************************************************************************
# **** Function: Gyro Fine Align (will be called in case of Channel 0177 output)           ****
# *********************************************************************************************
proc gyro_fine_align {} {
  global cdata FA_ANGLE PI

  set gyro_sign_minus  [string index $cdata(177) 0]
  set gyro_selection_a [string index $cdata(177) 1]
  set gyro_selection_b [string index $cdata(177) 2]
  set gyro_enable      [string index $cdata(177) 3]

  if {$gyro_sign_minus == 1} {set sign -1} else {set sign 1}
  set gyro_pulses [expr $sign * [convert_bin_dec [string range $cdata(177) 4 14]]]

  if {$gyro_selection_a == 0 && $gyro_selection_b == 1} {
     .text insert end "X-GYRO: $gyro_pulses\n"; .text yview moveto 1
     modify_gimbal_angle [expr $gyro_pulses * $FA_ANGLE] 0 0
  }

  if {$gyro_selection_a == 1 && $gyro_selection_b == 0} {
     .text insert end "Y-GYRO: $gyro_pulses\n"; .text yview moveto 1
     modify_gimbal_angle 0 [expr $gyro_pulses * $FA_ANGLE] 0
  }

  if {$gyro_selection_a == 1 && $gyro_selection_b == 1} {
     .text insert end "Z-GYRO: $gyro_pulses\n"; .text yview moveto 1
     modify_gimbal_angle 0 0 [expr $gyro_pulses * $FA_ANGLE]
  }

  move_fdai_marker
}


# *************************************************************************************************
# **** Function: Gyro Coarse Align (will be called in case of Channel 0174; 0175; 0176 output) ****
# *************************************************************************************************
proc gyro_coarse_align {par1} {
 global cdata CA_ANGLE bo error_x error_y error_z

 set sign [string index $cdata($par1) 0]
 if {$sign == 0} {set sign 1} else {set sign -1}
 set cdu_pulses [expr $sign * [convert_bin_dec [string range $cdata($par1) 1 14]]]

 # ---- Coarse Align Enable ----
 if {$bo(12,4) == 1} {
   if {$par1 == 174} {
      .text insert end "DRIVE CDU X: $cdu_pulses\n"; .text yview moveto 1
      modify_gimbal_angle [expr $cdu_pulses * $CA_ANGLE] 0 0
   }

   if {$par1 == 175} {
      .text insert end "DRIVE CDU Y: $cdu_pulses\n"; .text yview moveto 1
      modify_gimbal_angle 0 [expr $cdu_pulses * $CA_ANGLE] 0
   }

   if {$par1 == 176} {
      .text insert end "DRIVE CDU Z: $cdu_pulses\n"; .text yview moveto 1
      modify_gimbal_angle 0 0 [expr $cdu_pulses * $CA_ANGLE]
   }

   move_fdai_marker
 } else {
   # ---- Error Needles ----
   if {$par1 == 174} {set error_x [expr $error_x + $cdu_pulses]}
   if {$par1 == 175} {set error_y [expr $error_y + $cdu_pulses]}
   if {$par1 == 176} {set error_z [expr $error_z + $cdu_pulses]}
 }
}


# *************************************************************************************************
# **** Function: Modify a specific IMU Delta Gimbal-Angle par1=X; par2=Y; par3=Z               ****
# *************************************************************************************************
proc modify_gimbal_angle {dx dy dz} {
 global IMUX_ANGLE IMUY_ANGLE IMUZ_ANGLE ANGLE_INCR
 global PIMUX PIMUY PIMUZ bo gimbalLock
 global Omega_Roll Omega_Pitch Omega_Yaw DEG_TO_RAD RAD_TO_DEG PI 2PI

 if {$gimbalLock == 1 || $bo(12,5) == 1} {return}
 set ang_delta 0

 # ---- Modify X-Axis ----
 if {$dx != 0} {
   # ---- Calculate New X-Angle ----
   set IMUX_ANGLE [expr $IMUX_ANGLE + $dx]
   if {$IMUX_ANGLE < 0}   {set IMUX_ANGLE [expr $IMUX_ANGLE + 360]}
   if {$IMUX_ANGLE >= 360} {set IMUX_ANGLE [expr $IMUX_ANGLE - 360]}

   # ---- Calculate Delta between X-Angle and already feeded IMU X-Angle ----
   set dx [expr  $IMUX_ANGLE - $PIMUX]
   if {$dx < -180}   {set dx [expr $dx + 360]}
   if {$dx > 180} {set dx [expr $dx - 360]}

   # ---- Feed yaAGC with the new Angular Delta ----
   if {$dx >= 0} {set ANGLE_INCR_SIGN $ANGLE_INCR} else {set ANGLE_INCR_SIGN -$ANGLE_INCR}
   set ang_delta [expr abs($dx)]
   while {$ang_delta > $ANGLE_INCR} {
     set PIMUX [expr $PIMUX + $ANGLE_INCR_SIGN]
     set ang_delta [expr $ang_delta - $ANGLE_INCR]
     # ---- LM X-Axis/YAW-Axis ----
     if {$Omega_Yaw < 4} {
       if {$ANGLE_INCR_SIGN < 0} {write_socket "MCDU" 32} else {write_socket "PCDU" 32}
     } else {
       if {$ANGLE_INCR_SIGN < 0} {write_socket "MCDU_FAST" 32} else {write_socket "PCDU_FAST" 32}
     }
   }

   # ---- Check for Angular Boundaries ----
   if {$PIMUX < 0}    {set PIMUX [expr $PIMUX + 360]}
   if {$PIMUX >= 360} {set PIMUX [expr $PIMUX - 360]}
 }

 # ---- Modify Y-Axis ----
 if {$dy != 0} {
   # ---- Calculate new IMU Y-Angel ----
   set IMUY_ANGLE [expr $IMUY_ANGLE + $dy]
   if {$IMUY_ANGLE < 0}   {set IMUY_ANGLE [expr $IMUY_ANGLE + 360]}
   if {$IMUY_ANGLE >= 360} {set IMUY_ANGLE [expr $IMUY_ANGLE - 360]}

   # ---- Calculate Delta between Y-Angle and already feeded IMU Y-Angle ----
   set dy [expr  $IMUY_ANGLE - $PIMUY]
   if {$dy < -180}   {set dy [expr $dy + 360]}
   if {$dy > 180} {set dy [expr $dy - 360]}

   # ---- Feed yaAGC with the new Angular Delta ----
   if {$dy >= 0} {set ANGLE_INCR_SIGN $ANGLE_INCR} else {set ANGLE_INCR_SIGN -$ANGLE_INCR}
   set ang_delta [expr abs($dy)]
   while {$ang_delta > $ANGLE_INCR} {
     set PIMUY [expr $PIMUY + $ANGLE_INCR_SIGN]
     set ang_delta [expr $ang_delta - $ANGLE_INCR]
     # ---- LM Y-Axis/PITCH-Axis ----
     if {$Omega_Pitch < 4.0} {
       if {$ANGLE_INCR_SIGN < 0} {write_socket "MCDU" 33} else {write_socket "PCDU" 33}
     } else {
       if {$ANGLE_INCR_SIGN < 0} {write_socket "MCDU_FAST" 33} else {write_socket "PCDU_FAST" 33}
     }
   }

   # ---- Check for Angular Boundaries ----
   if {$PIMUY < 0}    {set PIMUY [expr $PIMUY + 360]}
   if {$PIMUY >= 360} {set PIMUY [expr $PIMUY - 360]}
 }

 # ---- Modify Z-Axis ----
 if {$dz != 0} {
   # ---- Calculate new IMU Z-Angel ----
   set IMUZ_ANGLE [expr $IMUZ_ANGLE + $dz]
   if {$IMUZ_ANGLE < 0}   {set IMUZ_ANGLE [expr $IMUZ_ANGLE + 360]}
   if {$IMUZ_ANGLE >= 360} {set IMUZ_ANGLE [expr $IMUZ_ANGLE - 360]}

   # ---- Check for Gimbal Lock ----
   if {$IMUZ_ANGLE > 85.1 && $IMUZ_ANGLE < 274.9} {set gimbalLock 1}
   
   # ---- Calculate Delta between Z-Angle and already feeded IMU Z-Angle ----
   set dz [expr  $IMUZ_ANGLE - $PIMUZ]
   if {$dz < -180}   {set dz [expr $dz + 360]}
   if {$dz > 180} {set dz [expr $dz - 360]}

   # ---- Feed yaAGC with the new Angular Delta ----
   if {$dz >= 0} {set ANGLE_INCR_SIGN $ANGLE_INCR} else {set ANGLE_INCR_SIGN -$ANGLE_INCR}
   set ang_delta [expr abs($dz)]
   while {$ang_delta > $ANGLE_INCR} {
     set PIMUZ [expr $PIMUZ + $ANGLE_INCR_SIGN]
     set ang_delta [expr $ang_delta - $ANGLE_INCR]
     # ---- LM Z-Axis/ROLL-Axis ----
     if {$Omega_Pitch < 4.0} {
       if {$ANGLE_INCR_SIGN < 0} {write_socket "MCDU" 34} else {write_socket "PCDU" 34}
     } else {
       if {$ANGLE_INCR_SIGN < 0} {write_socket "MCDU_FAST" 34} else {write_socket "PCDU_FAST" 34}
     }
   }

   # ---- Check for Angular Boundaries ----
   if {$PIMUZ < 0}    {set PIMUZ [expr $PIMUZ + 360]}
   if {$PIMUZ >= 360} {set PIMUZ [expr $PIMUZ - 360]}
 }
}


# *************************************************************************************************
# **** Function: Modify PIPA Values to match simulated Speed                                   ****
# *************************************************************************************************
proc modify_pipaXYZ {yawDeltaV pitchDeltaV rollDeltaV} {
 global PIPA_INCR PIPAX_COUNT PIPAY_COUNT PIPAZ_COUNT xVelocity yVelocity zVelocity
 global IMUX_ANGLE IMUY_ANGLE IMUZ_ANGLE RAD_TO_DEG DEG_TO_RAD PI 2PI

 # ---- Transform from Body Axes (Navigational Based) into Stable Member Axes ----
 set OGA [expr $IMUX_ANGLE * $DEG_TO_RAD]
 set IGA [expr $IMUY_ANGLE * $DEG_TO_RAD]
 set MGA [expr $IMUZ_ANGLE * $DEG_TO_RAD]

 set sinOG [expr sin($OGA)]
 set sinIG [expr sin($IGA)]
 set sinMG [expr sin($MGA)]
 set cosOG [expr cos($OGA)]
 set cosIG [expr cos($IGA)]
 set cosMG [expr cos($MGA)]

 set deltaVX [expr $cosMG*$cosIG*$yawDeltaV + (-1*$cosOG*$sinMG*$cosIG+$sinOG*$sinIG)*$pitchDeltaV + ($sinOG*$sinMG*$cosIG+$cosOG*$sinIG)*$rollDeltaV]
 set deltaVY [expr $sinMG*$yawDeltaV + $cosOG*$cosMG*$pitchDeltaV - $sinOG*$cosMG*$rollDeltaV]
 set deltaVZ [expr -1*$cosMG*$sinIG*$yawDeltaV + ($cosOG*$sinMG*$sinIG+$sinOG*$cosIG)*$pitchDeltaV + (-1*$sinOG*$sinMG*$sinIG+$cosOG*$cosIG)*$rollDeltaV]

 # ---- Integrate Speed ----
 set xVelocity [expr $xVelocity + $deltaVX]
 set yVelocity [expr $yVelocity + $deltaVY]
 set zVelocity [expr $zVelocity + $deltaVZ]

 # ---- Modify X-Counter ----
 set counts [expr ($xVelocity - $PIPA_INCR * $PIPAX_COUNT) / $PIPA_INCR]
 for {set i 1} {$i <= [expr abs($counts)]} {incr i 1} {
  if {$counts < 0} {incr PIPAX_COUNT -1; write_socket "MINC" 37}
  if {$counts > 0} {incr PIPAX_COUNT 1; write_socket "PINC" 37}
 }

 # ---- Modify Y-Counter ----
 set counts [expr ($yVelocity - $PIPA_INCR * $PIPAY_COUNT) / $PIPA_INCR]
 for {set i 1} {$i <= [expr abs($counts)]} {incr i 1} {
   if {$counts < 0} {incr PIPAY_COUNT -1; write_socket "MINC" 40}
   if {$counts > 0} {incr PIPAY_COUNT 1; write_socket "PINC" 40}
 }

 # ---- Modify Z-Counter ----
 set counts [expr ($zVelocity - $PIPA_INCR * $PIPAZ_COUNT) / $PIPA_INCR]
 for {set i 1} {$i <= [expr abs($counts)]} {incr i 1} {
   if {$counts < 0} {incr PIPAZ_COUNT -1; write_socket "MINC" 41}
   if {$counts > 0} {incr PIPAZ_COUNT 1; write_socket "PINC" 41}
 }
}


# *************************************************************************************************
# **** Function: Transform angular deltas in Body Axes into Stable Member angular deltas       ****
# *************************************************************************************************
proc Transform_BodyAxes_StableMember {dp dq dr} {
 global IMUX_ANGLE IMUY_ANGLE IMUZ_ANGLE RAD_TO_DEG DEG_TO_RAD PI 2PI

 set dp [expr $dp * $DEG_TO_RAD]
 set dq [expr $dq * $DEG_TO_RAD]
 set dr [expr $dr * $DEG_TO_RAD]

 set IMUX_ANGLE_b [expr $IMUX_ANGLE * $DEG_TO_RAD]
 set IMUY_ANGLE_b [expr $IMUY_ANGLE * $DEG_TO_RAD]
 set IMUZ_ANGLE_b [expr $IMUZ_ANGLE * $DEG_TO_RAD]

 set MPI [expr sin($IMUZ_ANGLE_b)]
 set MQI [expr cos($IMUZ_ANGLE_b) * cos($IMUX_ANGLE_b)]
 set MQM [expr sin($IMUX_ANGLE_b)]
 set MRI [expr -cos($IMUZ_ANGLE_b) * sin($IMUX_ANGLE_b)]
 set MRM [expr cos($IMUX_ANGLE_b)]
 set nenner [expr $MRM * $MQI - $MRI * $MQM]

 # ---- Calculate Angular Change ----
 set do_b [expr $dp - ($dq * $MRM * $MPI - $dr * $MQM * $MPI) / $nenner]
 set di_b [expr ($dq * $MRM - $dr * $MQM) / $nenner]
 set dm_b [expr ($dr * $MQI - $dq * $MRI) / $nenner]

 # ---- Check for Angular Boundaries ----
 if {$do_b < -$2PI}   {set do_b [expr $do_b + $2PI]}
 if {$do_b >= $2PI} {set do_b [expr $do_b - $2PI]}
 if {$di_b < -$2PI}   {set di_b [expr $di_b + $2PI]}
 if {$di_b >= $2PI} {set di_b [expr $di_b - $2PI]}
 if {$dm_b < -$2PI}   {set dm_b [expr $dm_b + $2PI]}
 if {$dm_b >= $2PI} {set dm_b [expr $dm_b - $2PI]}

 # ---- Rad to Deg and call of Gimbal Angle Modification ----
 modify_gimbal_angle [expr $do_b * $RAD_TO_DEG] [expr $di_b * $RAD_TO_DEG] [expr $dm_b * $RAD_TO_DEG]
}


# ********************************************************************************************
# **** Function:  IMU Cage Zero                                                           ****
# ********************************************************************************************
proc zeroIMU {} {
 global IMUX_ANGLE IMUY_ANGLE IMUZ_ANGLE
 global PIMUX PIMUY PIMUZ gimbalLock error_x error_y error_z

 set IMUX_ANGLE 0; set IMUY_ANGLE 0; set IMUZ_ANGLE 0
 set PIMUX 0; set PIMUY 0; set PIMUZ 0
 set error_x 0; set error_y 0; set error_z 0
 set gimbalLock 0
 if {[winfo exists .imu] == 1} {move_fdai_marker}
}
