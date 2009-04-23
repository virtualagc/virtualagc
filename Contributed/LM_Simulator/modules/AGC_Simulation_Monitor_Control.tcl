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
# **** Module:         AGC_Simulation_Monitor_Control.tcl                                 ****
# **** Main Program:   lm_simulator                                                       ****
# **** Author:         Stephan Hotto                                                      ****
# **** Date/Location:  21.04.07/Germany                                                   ****
# **** Version:        v1.0                                                               ****
# ********************************************************************************************

# ********************************************************************************************
# **** Function:  Create AGC Attitude GUI                                                 ****
# ********************************************************************************************
proc create_attitude_gui {} {
 global bo font11 font11b font1 font2 font3 colb Operating_System
 global IMUX_ANGLE IMUY_ANGLE IMUZ_ANGLE PIPAX_COUNT PIPAY_COUNT PIPAZ_COUNT
 global ROLL PITCH YAW RCS_IMPULSE_TIME xVelocity yVelocity zVelocity
 global DESCENT_ENGINE_FLAG Descent_Propulsion_Min_N Descent_Propulsion_Max_N Descent_Propellant_Mass_KG
 global Positive_Roll_Timer Negative_Roll_Timer
 global Positive_Pitch_Timer Negative_Pitch_Timer
 global Positive_Yaw_Timer Negative_Yaw_Timer RCS_IMPULSE_TIME RCS_JETS
 global ASCENT_ENGINE_FLAG LM_CONFIG

 if {[winfo exists .att] == 1} {destroy .att}

 toplevel .att -background $colb
 wm title .att "Simulation Monitor & Control"
 if {$Operating_System == "linux"} {
   wm geometry .att +860+460; wm geometry .att 270x380; wm minsize  .att 270 380
 } else {
   wm geometry .att +907+500; wm geometry .att 270x465; wm minsize  .att 270 465
 }
 wm iconname .att "LM Flight Simulation"

 frame .att.f1 -bg $colb; frame .att.f2 -bg $colb; frame .att.f3 -bg $colb; frame .att.f4 -bg $colb
 frame .att.f5 -bg $colb; frame .att.f6 -bg $colb; frame .att.f7 -bg $colb; frame .att.f8 -bg $colb
 frame .att.f9 -bg $colb; frame .att.f10 -bg $colb; frame .att.f11 -bg $colb; frame .att.f12 -bg $colb
 frame .att.f13 -bg $colb; frame .att.f14 -bg $colb; frame .att.f15 -bg $colb; frame .att.f16 -bg $colb
 frame .att.f17 -bg $colb; frame .att.f18 -bg $colb; frame .att.f19 -bg $colb; frame .att.f20 -bg $colb

 pack .att.f1 .att.f2 .att.f3 .att.f4 .att.f5 .att.f6 .att.f7 .att.f8 .att.f9 .att.f10 -side top -anchor w
 pack .att.f11 .att.f12 .att.f13 .att.f14 .att.f15 .att.f16 .att.f17 .att.f18 .att.f19 .att.f20 -side top -anchor w

 label .att.p1_l01 -text "SIMULATION PARAMETER:" -font ${font11b} -bg $colb
 pack .att.p1_l01 -side left -in .att.f1 -padx 1

 label .att.p1_l1 -text "SIMULATION TIME: " -font ${font11} -bg $colb
 label .att.p1_l2 -text "" -font ${font11} -bg $colb
 pack .att.p1_l1 .att.p1_l2 -side left -in .att.f2 -padx 1

 label .att.p1_l5 -text "LM WEIGHT:            " -font ${font11} -bg $colb
 label .att.p1_l6 -text "" -font ${font11} -bg $colb
 pack .att.p1_l5 .att.p1_l6 -side left -in .att.f3 -padx 1

 label .att.p1_20 -text "---------- Descent Engine ----------" -font ${font11b} -bg $colb
 pack .att.p1_20 -side top -in .att.f4 -padx 1

 label .att.p1_l3 -text "THRUST:               " -font ${font11} -bg $colb
 label .att.p1_l4 -text "" -font ${font11} -bg $colb
 pack .att.p1_l3 .att.p1_l4 -side left -in .att.f5 -padx 1

 label .att.p1_l7 -text "PROPELLANT:           " -font ${font11} -bg $colb
 label .att.p1_l8 -text "" -font ${font11} -bg $colb
 pack .att.p1_l7 .att.p1_l8 -side left -in .att.f6 -padx 1

 label .att.p1_l9 -text "FUEL FLOW:            " -font ${font11} -bg $colb
 label .att.p1_l10 -text "" -font ${font11} -bg $colb
 pack .att.p1_l9 .att.p1_l10 -side left -in .att.f7 -padx 1

 label .att.p1_l11 -text "ACCELERATION:         " -font ${font11} -bg $colb
 label .att.p1_l12 -text "" -font ${font11} -bg $colb
 pack .att.p1_l11 .att.p1_l12 -side left -in .att.f8 -padx 1

 checkbutton .att.p1_cb1 -text "DESCENT ENGINE ON/OFF" -variable DESCENT_ENGINE_FLAG -relief raised -borderwidth 2 -anchor w -font ${font11} -onvalue "1" -offvalue "0" -bg $colb
 pack .att.p1_cb1 -side left -in .att.f9 -padx 1 -pady 2

 scale .att.p1_s1 -label "Thrust \[N\]" -from $Descent_Propulsion_Min_N -to $Descent_Propulsion_Max_N -length 220 -orient horizontal -bg $colb -activebackground $colb -highlightbackground $colb -font ${font11b} 
 pack .att.p1_s1 -side left -in .att.f10 -padx 1 -pady 2

 label .att.p1_29 -text "-------- Stage Separation ----------" -font ${font11b} -bg $colb
 pack .att.p1_29 -side top -in .att.f11 -padx 1

 button .att.p1_b1 -text "SEPARATE ASCENT STAGE" -command {set LM_CONFIG "ASCENT"; set Descent_Propellant_Mass_KG 0; set LM_Weight_Descent_KG 0; .att.p1_cb2 configure -state active; .att.p1_cb1 configure -state disable; .att.p1_b1 configure -state disable -text "ASCENT STAGE SEPARATED"} -font ${font11} -fg red -bg $colb -pady 1
 pack .att.p1_b1 -side top -in .att.f12 -padx 1 -pady 2

 label .att.p1_21 -text "---------- Ascent Engine -----------" -font ${font11b} -bg $colb
 pack .att.p1_21 -side top -in .att.f13 -padx 1

 label .att.p1_l23 -text "PROPELLANT:           " -font ${font11} -bg $colb
 label .att.p1_l24 -text "" -font ${font11} -bg $colb
 pack .att.p1_l23 .att.p1_l24 -side left -in .att.f15 -padx 1

 label .att.p1_l25 -text "FUEL FLOW:            " -font ${font11} -bg $colb
 label .att.p1_l26 -text "" -font ${font11} -bg $colb
 pack .att.p1_l25 .att.p1_l26 -side left -in .att.f16 -padx 1

 label .att.p1_l27 -text "ACCELERATION:         " -font ${font11} -bg $colb
 label .att.p1_l28 -text "" -font ${font11} -bg $colb
 pack .att.p1_l27 .att.p1_l28 -side left -in .att.f17 -padx 1

 checkbutton .att.p1_cb2 -text "ASCENT ENGINE ON/OFF" -variable ASCENT_ENGINE_FLAG -relief raised -borderwidth 2 -anchor w -font ${font11} -onvalue "1" -offvalue "0" -bg $colb -state disabled
  pack .att.p1_cb2 .att.p1_cb2 -side left -in .att.f18 -padx 1 -pady 2

 label .att.p1_22 -text "--------------- RCS ----------------" -font ${font11b} -bg $colb
 pack .att.p1_22 -side top -in .att.f19 -padx 1

 label .att.p1_l15 -text "RCS PROPELLANT:     " -font ${font11} -bg $colb
 label .att.p1_l16 -text "" -font ${font11} -bg $colb
 pack .att.p1_l15 .att.p1_l16 -side left -in .att.f20 -padx 1
}


# ********************************************************************************************
# **** Function: Read Joystick Position par1 = Channel (octal)                            ****
# ********************************************************************************************
proc read_joystick {par1} {
 global cdata ROLL_TIMER PITCH_TIMER YAW_TIMER

 if {$par1 != 31} {
    set joy_dec [convert_bin15_dec $cdata($par1)]
    if {$joy_dec > 57} {set joy_dec [expr $joy_dec - 32767]}
    if {$par1 == 170} {set ROLL_TIMER $joy_dec}
    if {$par1 == 167} {set YAW_TIMER $joy_dec}
    if {$par1 == 166} {set PITCH_TIMER $joy_dec}
 } else {set joy_dec 0}

 .text insert end "Joystick: $par1 $cdata($par1)  $joy_dec\n"
 .text yview moveto 1
}


# ********************************************************************************************
# **** Function: Dynamic Simulation Model                                                 ****
# ********************************************************************************************
proc dynamic_simulation {} {
 global LM_Weight_KG Descent_Propulsion_Max_N Descent_Propulsion_Min_N LM_CONFIG a b c
 global Descent_Propellant_Mass_KG Propellant_Flow_Max_KGS Descent_Thrust_Procent
 global Descent_Acceleration DESCENT_ENGINE_FLAG Descent_Propulsion_N
 global Descent_Specific_Impulse_MS Descent_Fuel_Flow_SEC RCS_Propellant_Mass_KG
 global Omega_Roll Omega_Pitch Omega_Yaw
 global LM_Weight_Descent_KG LM_Weight_Ascent_KG Ascent_Propellant_Mass_KG 
 global Ascent_Fuel_Flow_SEC Ascent_Acceleration ASCENT_ENGINE_FLAG Ascent_Thrust_N
 global Ascent_Specific_Impulse_MS Delta_Time Delta_Time2
 global Alpha_Yaw Alpha_Pitch Alpha_Roll RAD_TO_DEG_PI4
 global Delta_Time2 ASCENT_SEPARATION

 # -------------------------- Main Engine Simulation ----------------------------------
 set LM_Weight_KG [expr $LM_Weight_Ascent_KG + $LM_Weight_Descent_KG]
 catch {set Descent_Propulsion_N [.att.p1_s1 get]}
 set Descent_Thrust_Procent [expr $Descent_Propulsion_N / $Descent_Propulsion_Max_N]

 catch {.att.p1_l2 configure -text [format "%10.1f SEC" $Simulation_Timer]}
 catch {.att.p1_l4 configure -text [format "%5.1f " [expr 100 * $Descent_Thrust_Procent]]%}
 catch {.att.p1_l6 configure -text [format "%5.0f KG" $LM_Weight_KG]}
 catch {.att.p1_l8 configure -text [format "%5.0f KG" $Descent_Propellant_Mass_KG]}
 catch {.att.p1_l10 configure -text [format "%5.2f KG/S" $Descent_Fuel_Flow_SEC]}
 catch {.att.p1_l12 configure -text [format "%5.3f M/S*S" $Descent_Acceleration]}
 catch {.att.p1_l16 configure -text [format "%5.1f KG" $RCS_Propellant_Mass_KG]}
 catch {.att.p1_l24 configure -text [format "%5.0f KG" $Ascent_Propellant_Mass_KG]}
 catch {.att.p1_l26 configure -text [format "%5.1f KG" $Ascent_Fuel_Flow_SEC]}
 catch {.att.p1_l28 configure -text [format "%5.3f M/S*S" $Ascent_Acceleration]}

 if {$DESCENT_ENGINE_FLAG == 1 && $Descent_Propellant_Mass_KG > 0} {
   set Descent_Fuel_Flow_SEC [expr $Descent_Propulsion_N / $Descent_Specific_Impulse_MS]
   set Descent_Fuel_Flow [expr $Descent_Fuel_Flow_SEC * $Delta_Time2]
   set Descent_Propellant_Mass_KG [expr $Descent_Propellant_Mass_KG - $Descent_Fuel_Flow]
   set LM_Weight_Descent_KG [expr $LM_Weight_Descent_KG - $Descent_Fuel_Flow]
   set Descent_Acceleration [expr $Descent_Propulsion_N / $LM_Weight_KG]
   set yawDeltaV [expr $Descent_Acceleration * $Delta_Time2]
   modify_pipaXYZ $yawDeltaV 0.0 0.0
 } else {
   set DESCENT_ENGINE_FLAG 0
   set Descent_Acceleration 0
   set Descent_Fuel_Flow_SEC 0
 }

 if {$ASCENT_ENGINE_FLAG == 1 && $Ascent_Propellant_Mass_KG > 0} {
   set Ascent_Fuel_Flow_SEC [expr $Ascent_Thrust_N / $Ascent_Specific_Impulse_MS]
   set Ascent_Fuel_Flow [expr $Ascent_Fuel_Flow_SEC * $Delta_Time2]
   set Ascent_Propellant_Mass_KG [expr $Ascent_Propellant_Mass_KG - $Ascent_Fuel_Flow]
   set LM_Weight_Ascent_KG [expr $LM_Weight_Ascent_KG - $Ascent_Fuel_Flow]
   set Ascent_Acceleration [expr $Ascent_Thrust_N / $LM_Weight_Ascent_KG]
   set yawDeltaV [expr $Ascent_Acceleration * $Delta_Time2]
   modify_pipaXYZ $yawDeltaV 0.0 0.0
 } else {
   set ASCENT_ENGINE_FLAG 0
   set Ascent_Acceleration 0
   set Ascent_Fuel_Flow_SEC 0
 }

 # ---- Calculate Single Jet Accelleration / Moment of Inertia depend on LM weight ----
 set m [expr $LM_Weight_KG / 65535.0]
 set Alpha_Yaw [expr $RAD_TO_DEG_PI4 * ($b($LM_CONFIG,YAW) + $a($LM_CONFIG,YAW)/($m + $c($LM_CONFIG,YAW)))]
 set Alpha_Pitch [expr $RAD_TO_DEG_PI4 * ($b($LM_CONFIG,PITCH) + $a($LM_CONFIG,PITCH)/($m + $c($LM_CONFIG,PITCH)))]
 set Alpha_Roll [expr $RAD_TO_DEG_PI4 * ($b($LM_CONFIG,ROLL) + $a($LM_CONFIG,ROLL)/($m + $c($LM_CONFIG,ROLL)))]

 # ---- Feed Angular Changes (Delta Time * Omega) into the IMU ----
 Transform_BodyAxes_StableMember [expr $Omega_Yaw * $Delta_Time2] [expr $Omega_Pitch * $Delta_Time2] [expr $Omega_Roll * $Delta_Time2]
}


# ********************************************************************************************
# **** Function: Check AGC Thruster Status and fire dedicated RCS Thruster                ****
# ********************************************************************************************
proc update_RCS {} {
 global RCS_Propellant_Mass_KG LM_Weight_KG LM_Weight_Ascent_KG RCS_Thrust_N RCS_Specific_Impulse_MS RCS_Thrust_N
 global Omega_Roll Omega_Pitch Omega_Yaw Delta_Time
 global Alpha_Yaw Alpha_Pitch Alpha_Roll
 global Acc_Yaw Acc_Pitch Acc_Roll
 global Q4U Q4D Q3U Q3D
 global Q2U Q2D Q1U Q1D
 global Q3A Q4F Q1F Q2A
 global Q2L Q3R Q4R Q1L

 if {$Q2D == 1 || $Q4U == 1} {set nv1 [expr $Q2D + $Q4U]} else {set nv1 0}
 if {$Q2U == 1 || $Q4D == 1} {set nv2 [expr -($Q2U + $Q4D)]} else {set nv2 0}

 if {$Q1D == 1 || $Q3U == 1} {set nu1 [expr $Q1D + $Q3U]} else {set nu1 0}
 if {$Q1U == 1 || $Q3D == 1} {set nu2 [expr -($Q1U + $Q3D)]} else {set nu2 0}

 if {$Q1F == 1 || $Q2L == 1 || $Q3A == 1 || $Q4R == 1} {set np1 [expr $Q1F + $Q2L + $Q3A + $Q4R]} else {set np1 0}
 if {$Q1L == 1 || $Q2A == 1 || $Q3R == 1 || $Q4F == 1} {set np2 [expr -($Q1L + $Q2A + $Q3R + $Q4F)]} else {set np2 0}

 set nv [expr $nv1 + $nv2]
 set nu [expr $nu1 + $nu2]
 set np [expr $np1 + $np2]

 # ---- Check for translational commands to calculate change in LM's speed along the pilot axis ----
 # ---- Along Yaw Axis ----
 if {$nv1 != 0 && [expr $nv1 + $nv2] == 0} {
   if {$Q2D == 1} {
     set RCS_Yaw [expr $Q2D + $Q4D]
   } else {
     set RCS_Yaw [expr -($Q2U + $Q4U)]
   }
 } else {
   set RCS_Yaw 0
 }

 if {$nu1 != 0 && [expr $nu1 + $nu2] == 0} {
   if {$Q1D == 1} {
     set RCS_Yaw [expr $RCS_Yaw + $Q1D + $Q3D]
   } else {
     set RCS_Yaw [expr $RCS_Yaw - $Q1U - $Q3U]
   }
 }

 if {$RCS_Yaw != 0} {
   set yawDeltaV [expr $Delta_Time * $RCS_Yaw * $RCS_Thrust_N / $LM_Weight_KG]
   modify_pipaXYZ $yawDeltaV 0.0 0.0
 }

 # ---- Along Pitch or Roll Axis ----
 if {$np1 != 0 && [expr $np1 + $np2] == 0} {
    # ---- Pitch Axis ----
    if {$Q1L == 1} {
      set PitchDeltaV [expr $Delta_Time * 2.0 * $RCS_Thrust_N / $LM_Weight_KG]
      modify_pipaXYZ 0.0 $PitchDeltaV 0.0
    }
    if {$Q3R == 1} {
      set PitchDeltaV [expr -$Delta_Time * 2.0 * $RCS_Thrust_N / $LM_Weight_KG]
      modify_pipaXYZ 0.0 $PitchDeltaV 0.0
    }
    # ---- Roll Axis ----
    if {$Q2A == 1} {
      set RollDeltaV [expr $Delta_Time * 2.0 * $RCS_Thrust_N / $LM_Weight_KG]
      modify_pipaXYZ 0.0 0.0 $RollDeltaV
    }
    if {$Q1F == 1} {
      set RollDeltaV [expr -$Delta_Time * 2.0 * $RCS_Thrust_N / $LM_Weight_KG]
      modify_pipaXYZ 0.0 0.0 $RollDeltaV
    }
 }

 # ---- Calculate Delta Omega, Omega and LM weight change ----
 if {$RCS_Propellant_Mass_KG > 0} {
   set Delta_Omega_Yaw [expr $Alpha_Yaw * $Delta_Time * $np]
   set Delta_Omega_Pitch [expr $Alpha_Pitch * $Delta_Time * ($nu - $nv)]
   set Delta_Omega_Roll [expr $Alpha_Roll * $Delta_Time * ($nu + $nv)]

   set Omega_Yaw [expr $Omega_Yaw + $Delta_Omega_Yaw]
   set Omega_Pitch [expr $Omega_Pitch + $Delta_Omega_Pitch]
   set Omega_Roll [expr $Omega_Roll + $Delta_Omega_Roll]

   set RCS_Fuel_Flow [expr (abs($nv1) + abs($nv2) + abs($nu1) + abs($nu2) + abs($np1) + abs($np2)) * $RCS_Thrust_N / $RCS_Specific_Impulse_MS * $Delta_Time]
   set LM_Weight_Ascent_KG [expr $LM_Weight_Ascent_KG - $RCS_Fuel_Flow]
   set RCS_Propellant_Mass_KG [expr $RCS_Propellant_Mass_KG - $RCS_Fuel_Flow]
 }
}
