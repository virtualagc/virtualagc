# Copyright 2005 Stephan Hotto <stephan.hotto@web.de>
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
# **** Module:         AGC_Attitude.tcl                                                   ****
# **** Main Program:   lm_simulator                                                       ****
# **** Author:         Stephan Hotto                                                      ****
# **** Date/Location:  18.09.05/Germany                                                   ****
# **** Version:        v0.6                                                               ****
# ********************************************************************************************

# ********************************************************************************************
# **** Function:  Create AGC Attitude GUI                                                 ****
# ********************************************************************************************
proc create_attitude_gui {} {
 global bo font11 font11b font1 font2 font3 colb
 global IMUX_ANGLE IMUY_ANGLE IMUZ_ANGLE PIPAX_COUNT PIPAY_COUNT PIPAZ_COUNT
 global ROLL PITCH YAW RCS_IMPULSE_TIME xVelocity yVelocity zVelocity
 global Descent_Propulsion_Max_N Descent_Propulsion_Min_N DESCENT_ENGINE_FLAG
 global Positive_Roll_Timer Negative_Roll_Timer
 global Positive_Pitch_Timer Negative_Pitch_Timer
 global Positive_Yaw_Timer Negative_Yaw_Timer RCS_IMPULSE_TIME RCS_JETS
 
 if {[winfo exists .att] == 1} {destroy .att}

 toplevel .att -background $colb
 wm title .att "LM Attitude & Speed Simulation"
 wm geometry .att +725+460
 wm geometry .att 270x250
 wm minsize  .att 270 250
 wm iconname .att "LM Flight Simulation"
 
 frame .att.p1 -bg $colb; frame .att.p1_f0 -bg $colb; frame .att.p1_f1 -bg $colb
 frame .att.p1_f2 -bg $colb; frame .att.p1_f3 -bg $colb; frame .att.p1_f4 -bg $colb
 frame .att.p1_f5 -bg $colb; frame .att.p1_f6 -bg $colb; frame .att.p1_f7 -bg $colb
 frame .att.p1_f8 -bg $colb; frame .att.p1_f9 -bg $colb; frame .att.p1_f10 -bg $colb
 frame .att.p1_f11 -bg $colb; frame .att.p1_f12 -bg $colb
 
 frame .att.f00a -bg $colb; frame .att.f0a -bg $colb; frame .att.f01a -bg $colb; frame .att.f1a -bg $colb; frame .att.f2a -bg $colb; frame .att.f3a -bg $colb; frame .att.f4a -bg $colb
 frame .att.f5a -bg $colb; frame .att.f6a -bg $colb; frame .att.f7a -bg $colb; frame .att.f8a -bg $colb
 frame .att.f9a -bg $colb
 pack .att.p1 .att.f00a .att.f0a .att.f01a .att.f1a .att.f2a .att.f3a .att.f4a .att.f5a -side top -anchor w
 pack .att.f6a .att.f7a .att.f8a .att.f9a -side top -anchor w
 
 pack .att.p1_f0 .att.p1_f1 .att.p1_f2 .att.p1_f3 .att.p1_f4 .att.p1_f5 .att.p1_f6 -in .att.p1 -side top -anchor w
 pack .att.p1_f10 .att.p1_f11 .att.p1_f12 -in .att.p1 -side top -anchor w
 pack .att.p1_f7 .att.p1_f8 .att.p1_f9 -in .att.p1 -side top -anchor w
 
 label .att.p1_l01 -text "SIMULATION PARAMETER:" -font ${font11b} -bg $colb
 pack .att.p1_l01 -side left -in .att.p1_f0 -padx 1
 
 label .att.p1_l1 -text "SIMULATION TIME: " -font ${font11} -bg $colb
 label .att.p1_l2 -text "" -font ${font11} -bg $colb
 pack .att.p1_l1 .att.p1_l2 -side left -in .att.p1_f1 -padx 1
 
 label .att.p1_l3 -text "DESCENT THRUST:       " -font ${font11} -bg $colb
 label .att.p1_l4 -text "" -font ${font11} -bg $colb
 pack .att.p1_l3 .att.p1_l4 -side left -in .att.p1_f2 -padx 1
 
 label .att.p1_l5 -text "LM WEIGHT:            " -font ${font11} -bg $colb
 label .att.p1_l6 -text "" -font ${font11} -bg $colb
 pack .att.p1_l5 .att.p1_l6 -side left -in .att.p1_f3 -padx 1
 
 label .att.p1_l7 -text "DESCENT PROPELLANT:   " -font ${font11} -bg $colb
 label .att.p1_l8 -text "" -font ${font11} -bg $colb
 pack .att.p1_l7 .att.p1_l8 -side left -in .att.p1_f4 -padx 1
 
 label .att.p1_l9 -text "FUEL FLOW:            " -font ${font11} -bg $colb
 label .att.p1_l10 -text "" -font ${font11} -bg $colb
 pack .att.p1_l9 .att.p1_l10 -side left -in .att.p1_f5 -padx 1
 
 label .att.p1_l11 -text "ACCELERATION:         " -font ${font11} -bg $colb
 label .att.p1_l12 -text "" -font ${font11} -bg $colb
 pack .att.p1_l11 .att.p1_l12 -side left -in .att.p1_f6 -padx 1

 label .att.p1_l15 -text "RCS PROPELLANT:       " -font ${font11} -bg $colb
 label .att.p1_l16 -text "" -font ${font11} -bg $colb
 pack .att.p1_l15 .att.p1_l16 -side left -in .att.p1_f10 -padx 1
  
 label .att.p1_l13 -text "----------------------------------" -font ${font1} -bg $colb
 pack .att.p1_l13 -side left -in .att.p1_f7 -padx 1
 
 checkbutton .att.p1_cb1 -text "DESCENT ENGINE ON/OFF" -variable DESCENT_ENGINE_FLAG -relief raised -borderwidth 2 -anchor w -font ${font11} -onvalue "1" -offvalue "0" -bg $colb
 scale .att.p1_s1 -label "Thrust \[N\]" -from $Descent_Propulsion_Min_N -to $Descent_Propulsion_Max_N -length 250 -orient horizontal -bg $colb -activebackground $colb -highlightbackground $colb -font ${font11b} 
 pack .att.p1_cb1 .att.p1_s1 -side top -in .att.p1_f8 -padx 1
  
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
 
 #.text insert end "Joystick: $par1 $cdata($par1)  $joy_dec\n"
 #.text yview moveto 1
    
}


# ********************************************************************************************
# **** Function: Simulation Loop                                                          ****
# ********************************************************************************************
proc dynamic_simulation {} {
 global Simulation_Timer LM_Weight_KG Descent_Propulsion_Max_N Descent_Propulsion_Min_N
 global Descent_Propellant_Mass_KG Propellant_Flow_Max_KGS Descent_Thrust_Procent
 global Descent_Acceleration Delta_Time DESCENT_ENGINE_FLAG Descent_Propulsion_N yawDeltaV
 global simcount2 Descent_Specific_Impulse_MS Descent_Fuel_Flow_SEC RCS_Propellant_Mass_KG
 global Omega_Roll Omega_Pitch Omega_Yaw 

 # -------------------------- Main Engine Simulation ----------------------------------
 catch {set Descent_Propulsion_N [.att.p1_s1 get]}
 set Descent_Thrust_Procent [expr $Descent_Propulsion_N / $Descent_Propulsion_Max_N]

 catch {.att.p1_l2 configure -text [format "%10.1f SEC" $Simulation_Timer]}
 catch {.att.p1_l4 configure -text [format "%5.1f " [expr 100 * $Descent_Thrust_Procent]]%}
 catch {.att.p1_l6 configure -text [format "%5.0f KG" $LM_Weight_KG]}
 catch {.att.p1_l8 configure -text [format "%5.0f KG" $Descent_Propellant_Mass_KG]}
 catch {.att.p1_l10 configure -text [format "%5.2f KG/S" $Descent_Fuel_Flow_SEC]}
 catch {.att.p1_l12 configure -text [format "%5.3f M/S*S" $Descent_Acceleration]}
 catch {.att.p1_l16 configure -text [format "%5.1f KG" $RCS_Propellant_Mass_KG]}
 
 if {$DESCENT_ENGINE_FLAG == 1 && $Descent_Propellant_Mass_KG > 0} {
   set Descent_Fuel_Flow_SEC [expr $Descent_Propulsion_N / $Descent_Specific_Impulse_MS]
   set Descent_Fuel_Flow [expr $Descent_Fuel_Flow_SEC * $Delta_Time]
   set Descent_Propellant_Mass_KG [expr $Descent_Propellant_Mass_KG - $Descent_Fuel_Flow]
   set LM_Weight_KG [expr $LM_Weight_KG - $Descent_Fuel_Flow]
   set Descent_Acceleration [expr $Descent_Propulsion_N / $LM_Weight_KG]
   set yawDeltaV [expr $yawDeltaV + $Descent_Acceleration * $Delta_Time]
 } else {
   set DESCENT_ENGINE_FLAG 0
   set Descent_Acceleration 0
   set Descent_Fuel_Flow_SEC 0
 }
 
 update_RCS
 
 set Delta_Theta_Roll [expr $Omega_Roll * $Delta_Time]
 set Delta_Theta_Pitch [expr $Omega_Pitch * $Delta_Time]
 set Delta_Theta_Yaw [expr $Omega_Yaw * $Delta_Time]
 
 Transform_NB_SM "ROLL" -$Delta_Theta_Roll
 Transform_NB_SM "PITCH" -$Delta_Theta_Pitch
 Transform_NB_SM "YAW" -$Delta_Theta_Yaw
 
 incr simcount2 1
 if {$simcount2 == 5} {
    set simcount2 0
    modify_pipaXYZ
    catch {move_fdai_marker}
    set yawDeltaV 0
 }
 
}


# ********************************************************************************************
# **** Function: Check AGC Thruster Status and fire dedicated RCS Thruster                ****
# ********************************************************************************************
proc update_RCS {} {
 global bo
  
  set Q4U $bo(5,1); set Q4D $bo(5,2); set Q3U $bo(5,3); set Q3D $bo(5,4)
  set Q2U $bo(5,5); set Q2D $bo(5,6); set Q1U $bo(5,7); set Q1D $bo(5,8)
  
  set Q3A $bo(6,1); set Q4F $bo(6,2); set Q1F $bo(6,3); set Q2A $bo(6,4)
  set Q2L $bo(6,5); set Q3R $bo(6,6); set Q4R $bo(6,7); set Q1L $bo(6,8)
  
  if {$Q4U == 0 && $Q4D == 0 && $Q3U == 0 && $Q3D == 0 && $Q2U == 0 && $Q2D == 0 && $Q1U == 0 && $Q1D == 0 && $Q3A == 0 && $Q4F == 0 && $Q1F == 0 && $Q2A == 0 && $Q2L == 0 && $Q3R == 0 && $Q4R == 0 && $Q1L == 0} {return}
  
  # ---- V-Axis 2 Thruster ----
  if {$Q1U == 0 && $Q1D == 0 && $Q2D == 1 && $Q3U == 0 && $Q3D == 0 && $Q4U == 1} {
     fire_rcs_thruster "V_POS" 2
  } elseif {$Q1U == 0 && $Q1D == 0 && $Q2U == 1 && $Q3U == 0 && $Q3D == 0 && $Q4D == 1} {
     fire_rcs_thruster "V_NEG" 2
  } 
  
  # ---- U-Axis 2 Thruster ----
  if {$Q1D == 1 && $Q2U == 0 && $Q2D == 0 && $Q3U == 1 && $Q4U == 0 && $Q4D == 0} {
     fire_rcs_thruster "U_POS" 2
  } elseif {$Q1U == 1 && $Q2U == 0 && $Q2D == 0 && $Q3D == 1 && $Q4U == 0 && $Q4D == 0} {
     fire_rcs_thruster "U_NEG" 2
  }
   
  # ---- YAW 4 Thruster----
  if {$Q1F == 1 && $Q2L == 1 && $Q3A == 1 && $Q4R == 1} {
     fire_rcs_thruster "YAW_POS" 4
  } elseif {$Q1L == 1 && $Q2A == 1 && $Q3R == 1 && $Q4F == 1} {
     fire_rcs_thruster "YAW_NEG" 4
  }
  
  # ---- YAW 2 Thruster 1st Pair ----
  if {$Q1F == 0 && $Q2L == 1 && $Q3A == 0 && $Q4R == 1} {
     fire_rcs_thruster "YAW_POS" 2
  } elseif {$Q1L == 0 && $Q2A == 1 && $Q3R == 0 && $Q4F == 1} {
     fire_rcs_thruster "YAW_NEG" 2
  }
  
  # ---- YAW 2 Thruster 2nd Pair ----
  if {$Q1F == 1 && $Q2L == 0 && $Q3A == 1 && $Q4R == 0} {
     fire_rcs_thruster "YAW_POS" 2
  } elseif {$Q1L == 1 && $Q2A == 0 && $Q3R == 1 && $Q4F == 0} {
     fire_rcs_thruster "YAW_NEG" 2
  } 

  # ---- Pitch 4 Thruster----
  if {$Q1U == 1 && $Q2D == 1 && $Q3D == 1 && $Q4U == 1} {
     fire_rcs_thruster "PITCH_NEG" 4
  } elseif {$Q1D == 1 && $Q2U == 1 && $Q3U == 1 && $Q4D == 1} {
     fire_rcs_thruster "PITCH_POS" 4
  }
  
   # ---- Pitch 2 Thruster (Minimum Impulse Mode)----
  if {$Q1U == 0 && $Q1D == 0 && $Q2U == 0 && $Q2D == 0 && $Q3D == 1 && $Q4U == 1} {
     fire_rcs_thruster "PITCH_NEG" 2
  } elseif {$Q1D == 1 && $Q2U == 1 && $Q3U == 0 && $Q3D == 0 && $Q4U == 0 && $Q4D == 0} {
     fire_rcs_thruster "PITCH_POS" 2
  }
    
  # ---- Roll 4 Thruster ----
  if {$Q1D == 1 && $Q2D == 1 && $Q3U == 1 && $Q4U == 1} {
     fire_rcs_thruster "ROLL_POS" 4
  } elseif {$Q1U == 1 && $Q2U == 1 && $Q3D == 1 && $Q4D == 1} {
     fire_rcs_thruster "ROLL_NEG" 4
  }
  
  # ---- Roll 2 Thruster (Minimum Impulse Mode) ----
  if {$Q1D == 1 && $Q2U == 0 && $Q2D == 0 && $Q3U == 0 && $Q3D == 0 && $Q4U == 1} {
     fire_rcs_thruster "ROLL_POS" 2
  } elseif {$Q1U == 0 && $Q1D == 0 && $Q2U == 1 && $Q3D == 1 && $Q4U == 0 && $Q4D == 0} {
     fire_rcs_thruster "ROLL_NEG" 2
  }
  
}


# ********************************************************************************************
# **** Function: RCS Thruster firing par1=Direction; par2=Number of Thruster              ****
# ********************************************************************************************
proc fire_rcs_thruster {par1 par2} {
 global LM_Weight_KG RCS_Propellant_Mass_KG RCS_Thrust_N RCS_Specific_Impulse_MS
 global Omega_Roll Omega_Pitch Omega_Yaw Moment_of_Inertia_Factor Delta_Time

 # -------------------------- RCS Thruster Simulation ---------------------------------
 if {$RCS_Propellant_Mass_KG <= 0} {return}
 
 set Moment_of_Inertia [expr $Moment_of_Inertia_Factor * $LM_Weight_KG]
 set Tau [expr $par2 * 8 * 1.68 * $RCS_Thrust_N]
 set Alpha [expr $Tau / $Moment_of_Inertia]
 set DeltaOmega [expr $Alpha * $Delta_Time]
 
 # ---- V-Axis ----
 if {$par1 == "V_POS"} {
   set Omega_Pitch [expr $Omega_Pitch - $DeltaOmega * 0.0707]
   set Omega_Roll [expr $Omega_Roll + $DeltaOmega * 0.0707]
 }
 
 if {$par1 == "V_NEG"} {
   set Omega_Pitch [expr $Omega_Pitch + $DeltaOmega * 0.0707]
   set Omega_Roll [expr $Omega_Roll - $DeltaOmega * 0.0707]
 }
 
 # ---- U-Axis ----
 if {$par1 == "U_POS"} {
   set Omega_Pitch [expr $Omega_Pitch + $DeltaOmega * 0.0707]
   set Omega_Roll [expr $Omega_Roll + $DeltaOmega * 0.0707]
 }
 
 if {$par1 == "U_NEG"} {
   set Omega_Pitch [expr $Omega_Pitch - $DeltaOmega * 0.0707]
   set Omega_Roll [expr $Omega_Roll - $DeltaOmega * 0.0707]
 }
 
 # ---- Roll ----
 if {$par1 == "ROLL_NEG"} {
   set Omega_Roll [expr $Omega_Roll - $DeltaOmega]
 }
 
 if {$par1 == "ROLL_POS"} {
   set Omega_Roll [expr $Omega_Roll + $DeltaOmega]
 }
 
 # ---- Pitch ----
 if {$par1 == "PITCH_NEG"} {
   set Omega_Pitch [expr $Omega_Pitch - $DeltaOmega]
 }
 
 if {$par1 == "PITCH_POS"} {
   set Omega_Pitch [expr $Omega_Pitch + $DeltaOmega]
 }
 
 # ---- Yaw ----
 if {$par1 == "YAW_NEG"} {
   set Omega_Yaw [expr $Omega_Yaw - $DeltaOmega]
 }
 
 if {$par1 == "YAW_POS"} {
   set Omega_Yaw [expr $Omega_Yaw + $DeltaOmega]
 }
 
 set RCS_Fuel_Flow [expr $par2 * $RCS_Thrust_N / $RCS_Specific_Impulse_MS * $Delta_Time]
 set LM_Weight_KG [expr $LM_Weight_KG - $RCS_Fuel_Flow]
 set RCS_Propellant_Mass_KG [expr $RCS_Propellant_Mass_KG - $RCS_Fuel_Flow]
 
}

