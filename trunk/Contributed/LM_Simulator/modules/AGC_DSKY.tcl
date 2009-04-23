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
# **** Module:         AGC_DSKY.tcl                                                       ****
# **** Main Program:   lm_system_simulator                                                ****
# **** Author:         Stephan Hotto                                                      ****
# **** Date/Location:  21.04.07/Germany                                                   ****
# **** Version:        v1.0                                                               ****
# ********************************************************************************************

# ********************************************************************************************
# **** Function:  Create DSKY GUI                                                         ****
# ********************************************************************************************
proc create_dsky {} {
 global b bo font1 font2 font3 font4 colb colb2 colb3 Operating_System

 if {[winfo exists .dsky] == 1} {destroy .dsky}

 toplevel .dsky
 wm title .dsky "DSKY Lite"
 if {$Operating_System == "linux"} {
   wm geometry .dsky +0+460; wm geometry .dsky 400x465; wm minsize .dsky 400 465
 } else {
   wm geometry .dsky +0+500; wm geometry .dsky 403x465; wm minsize .dsky 403 465
 }
 wm iconname .dsky "DSKY Lite"

 .dsky configure -background $colb

 # --------------- Keyboard Frames -------------------
 frame .dsky.f1p -bg $colb; frame .dsky.f2p -bg $colb
 pack .dsky.f1p .dsky.f2p -side top -anchor w -padx 5

 frame .dsky.f1a -bg $colb; frame .dsky.f1b -bg $colb3
 pack .dsky.f1a .dsky.f1b -in .dsky.f1p -side left -anchor n -padx 25 -pady 10

 frame .dsky.f2a -bg $colb; frame .dsky.f2b -bg $colb; frame .dsky.f2c -bg $colb
 pack .dsky.f2a .dsky.f2b .dsky.f2c -in .dsky.f2p -side left -anchor w

 frame .dsky.f1 -bg $colb; frame .dsky.f2 -bg $colb; frame .dsky.f3 -bg $colb
 pack .dsky.f1 .dsky.f2 .dsky.f3 -in .dsky.f2b -side top -anchor w

 # -------------- Display (Signal Lamps) Frames ------
 frame .dsky.fdl1 -bg $colb; frame .dsky.fdl2 -bg $colb; frame .dsky.fdl3 -bg $colb
 frame .dsky.fdl4 -bg $colb; frame .dsky.fdl5 -bg $colb; frame .dsky.fdl6 -bg $colb
 frame .dsky.fdl7 -bg $colb

 pack .dsky.fdl1 .dsky.fdl2 .dsky.fdl3 .dsky.fdl4 .dsky.fdl5 .dsky.fdl6 .dsky.fdl7 -in .dsky.f1a -side top -anchor w

 # -------------- Display Frames ---------------------
 frame .dsky.f1b1 -bg $colb3; frame .dsky.f1b2 -bg $colb3
 pack .dsky.f1b1 .dsky.f1b2 -side top -in .dsky.f1b -anchor n

 frame .dsky.f1b1a -bg $colb3; frame .dsky.f1b1b -bg $colb3; frame .dsky.f1b1e -bg $colb3
 pack .dsky.f1b1a -side left -in .dsky.f1b1 -anchor n
 pack .dsky.f1b1e -side left -in .dsky.f1b1 -anchor n -padx 23
 pack .dsky.f1b1b -side left -in .dsky.f1b1 -anchor n

 frame .dsky.fd1a -bg $colb3; frame .dsky.fd2a -bg $colb3; frame .dsky.fd3a -bg $colb3; frame .dsky.fd4a -bg $colb3; 
 frame .dsky.fd1b -bg $colb3; frame .dsky.fd2b -bg $colb3; frame .dsky.fd3b -bg $colb3; frame .dsky.fd4b -bg $colb3; 

 pack .dsky.fd1a .dsky.fd2a .dsky.fd3a .dsky.fd4a -in .dsky.f1b1a -side top -anchor w -pady 1
 pack .dsky.fd1b .dsky.fd2b .dsky.fd3b .dsky.fd4b -in .dsky.f1b1b -side top -anchor w -pady 1

 frame .dsky.fd5 -bg $colb3; frame .dsky.fd6 -bg $colb3; frame .dsky.fd7 -bg $colb3
 frame .dsky.fd51 -bg $colb3; frame .dsky.fd61 -bg $colb3; frame .dsky.fd71 -bg $colb3

 pack .dsky.fd51 -in .dsky.f1b2 -side top -anchor n
 pack .dsky.fd5 -in .dsky.f1b2 -side top -anchor w
 pack .dsky.fd61 -in .dsky.f1b2 -side top -anchor n
 pack .dsky.fd6 -in .dsky.f1b2 -side top -anchor w
 pack .dsky.fd71 -in .dsky.f1b2 -side top -anchor n
 pack .dsky.fd7 -in .dsky.f1b2 -side top -anchor w

 # --------------- Number Pad -------------------

 # --------------- Number pad first row ------------------------
 button .dsky.b1 -text " + " -relief raised -borderwidth 2 -bg black -fg white -activebackground black -activeforeground white -anchor w -font ${font3} -command {set bmask(15) "000000000011111"; set wdata(15) "000000000011010"; write_socket w 15} -padx 10
 pack .dsky.b1 -side left -in .dsky.f1 -anchor w -fill x -fill y -padx 2 -pady 2

 button .dsky.b2 -text " 7 " -relief raised -borderwidth 2 -bg black -fg white -activebackground black -activeforeground white -anchor w -font ${font3} -command {set bmask(15) "000000000011111"; set wdata(15) "000000000000111"; write_socket w 15} -padx 10
 pack .dsky.b2 -side left -in .dsky.f1 -anchor w -fill x -fill y -padx 2 -pady 2

 button .dsky.b3 -text " 8 " -relief raised -borderwidth 2 -bg black -fg white -activebackground black -activeforeground white -anchor w -font ${font3} -command {set bmask(15) "000000000011111"; set wdata(15) "000000000001000"; write_socket w 15} -padx 10
 pack .dsky.b3 -side left -in .dsky.f1 -anchor w -fill x -fill y -padx 2 -pady 2

 button .dsky.b4 -text " 9 " -relief raised -borderwidth 2 -bg black -fg white -activebackground black -activeforeground white -anchor w -font ${font3} -command {set bmask(15) "000000000011111"; set wdata(15) "000000000001001"; write_socket w 15} -padx 10
 pack .dsky.b4 -side left -in .dsky.f1 -anchor w -fill x -fill y -padx 2 -pady 2

 button .dsky.b5 -text "CLR" -relief raised -borderwidth 2 -bg black -fg white -activebackground black -activeforeground white -anchor w -font ${font3} -command {set bmask(15) "000000000011111"; set wdata(15) "000000000011110"; write_socket w 15} -padx 10 -pady 12
 pack .dsky.b5 -side left -in .dsky.f1 -anchor w -fill x -fill y -padx 2 -pady 2

 # --------------- Number pad second row ------------------------ 
 button .dsky.b6 -text " - " -relief raised -borderwidth 2 -bg black -fg white -activebackground black -activeforeground white -anchor w -font ${font3} -command {set bmask(15) "000000000011111"; set wdata(15) "000000000011011"; write_socket w 15} -padx 10
 pack .dsky.b6 -side left -in .dsky.f2 -anchor w -fill x -fill y -padx 2 -pady 2

 button .dsky.b7 -text " 4 " -relief raised -borderwidth 2 -bg black -fg white -activebackground black -activeforeground white -anchor w -font ${font3} -command {set bmask(15) "000000000011111"; set wdata(15) "000000000000100"; write_socket w 15} -padx 10
 pack .dsky.b7 -side left -in .dsky.f2 -anchor w -fill x -fill y -padx 2 -pady 2

 button .dsky.b8 -text " 5 " -relief raised -borderwidth 2 -bg black -fg white -activebackground black -activeforeground white -anchor w -font ${font3} -command {set bmask(15) "000000000011111"; set wdata(15) "000000000000101"; write_socket w 15} -padx 10
 pack .dsky.b8 -side left -in .dsky.f2 -anchor w -fill x -fill y -padx 2 -pady 2

 button .dsky.b9 -text " 6 " -relief raised -borderwidth 2 -bg black -fg white -activebackground black -activeforeground white -anchor w -font ${font3} -command {set bmask(15) "000000000011111"; set wdata(15) "000000000000110"; write_socket w 15} -padx 10
 pack .dsky.b9 -side left -in .dsky.f2 -anchor w -fill x -fill y -padx 2 -pady 2

 button .dsky.b10 -text "PRO" -relief raised -borderwidth 2 -bg black -fg white -activebackground black -activeforeground white -anchor w -font ${font3} -command {set bmask(32) "010000000000000"; set b(32,14) 0; write_socket b 32; after 200 {reset_crew_buttons}} -padx 10 -pady 12
 pack .dsky.b10 -side left -in .dsky.f2 -anchor w -fill x -fill y -padx 2 -pady 2

 # --------------- Number pad third row ------------------------
 button .dsky.b11 -text " 0 " -relief raised -borderwidth 2 -bg black -fg white -activebackground black -activeforeground white -anchor w -font ${font3} -command {set bmask(15) "000000000011111"; set wdata(15) "000000000010000"; write_socket w 15} -padx 10
 pack .dsky.b11 -side left -in .dsky.f3 -anchor w -fill x -fill y -padx 2 -pady 2

 button .dsky.b12 -text " 1 " -relief raised -borderwidth 2 -bg black -fg white -activebackground black -activeforeground white -anchor w -font ${font3} -command {set bmask(15) "000000000011111"; set wdata(15) "000000000000001"; write_socket w 15} -padx 10
 pack .dsky.b12 -side left -in .dsky.f3 -anchor w -fill x -fill y -padx 2 -pady 2

 button .dsky.b13 -text " 2 " -relief raised -borderwidth 2 -bg black -fg white -activebackground black -activeforeground white -anchor w -font ${font3} -command {set bmask(15) "000000000011111"; set wdata(15) "000000000000010"; write_socket w 15} -padx 10
 pack .dsky.b13 -side left -in .dsky.f3 -anchor w -fill x -fill y -padx 2 -pady 2

 button .dsky.b14 -text " 3 " -relief raised -borderwidth 2 -bg black -fg white -activebackground black -activeforeground white -anchor w -font ${font3} -command {set bmask(15) "000000000011111"; set wdata(15) "000000000000011"; write_socket w 15} -padx 10
 pack .dsky.b14 -side left -in .dsky.f3 -anchor w -fill x -fill y -padx 2 -pady 2

 button .dsky.b15 -text "KEY\nREL" -relief raised -borderwidth 2 -bg black -fg white -activebackground black -activeforeground white -anchor w -font ${font3} -command {set bmask(15) "000000000011111"; set wdata(15) "000000000011001"; write_socket w 15} -padx 10 -pady 5
 pack .dsky.b15 -side left -in .dsky.f3 -anchor w -fill x -fill y -padx 2 -pady 2 

 # --------------- First Column ----------------------------
 button .dsky.b16 -text "VERB" -relief raised -borderwidth 2 -bg black -fg white -activebackground black -activeforeground white -anchor w -font ${font3} -command {set bmask(15) "000000000011111"; set wdata(15) "000000000010001"; write_socket w 15} -padx 10 -pady 12
 pack .dsky.b16 -side top -in .dsky.f2a -anchor w -fill x -fill y -pady 2 -padx 2

 button .dsky.b17 -text "NOUN" -relief raised -borderwidth 2 -bg black -fg white -activebackground black -activeforeground white -anchor w -font ${font3} -command {set bmask(15) "000000000011111"; set wdata(15) "000000000011111"; write_socket w 15} -padx 10 -pady 12
 pack .dsky.b17 -side top -in .dsky.f2a -anchor w -fill x -fill y -pady 2 -padx 2

 # --------------- Second Column ----------------------------
 button .dsky.b18 -text "ENTR" -relief raised -borderwidth 2 -bg black -fg white -activebackground black -activeforeground white -anchor w -font ${font3} -command {set bmask(15) "000000000011111"; set wdata(15) "000000000011100"; write_socket w 15} -padx 10 -pady 12
 pack .dsky.b18 -side top -in .dsky.f2c -anchor w -fill x -fill y -pady 2 -padx 2

 button .dsky.b19 -text "RSET" -relief raised -borderwidth 2 -bg black -fg white -activebackground black -activeforeground white -anchor w -font ${font3} -command {set bmask(15) "000000000011111"; set wdata(15) "000000000010010"; write_socket w 15} -padx 10 -pady 12
 pack .dsky.b19 -side top -in .dsky.f2c -anchor w -fill x -fill y -pady 2 -padx 2

 # --------------- DSKY Signal Lamps -------------------
 label .dsky.l_11_3 -text "UPLINK \nACTY" -font ${font1} -bg $colb2 -padx 4
 pack .dsky.l_11_3 -side left -in .dsky.fdl1 -anchor w -fill x -fill y -pady 2 -padx 2

 label .dsky.l_11_4 -text " TEMP  " -font ${font1} -bg $colb2 -padx 4
 pack .dsky.l_11_4 -side left -in .dsky.fdl1 -anchor w -fill x -fill y -pady 2 -padx 2
 # ----
 label .dsky.l_10_4 -text "NO ATT " -font ${font1} -bg $colb2 -padx 4
 pack .dsky.l_10_4 -side left -in .dsky.fdl2 -anchor w -fill x -fill y -pady 2 -padx 2

 label .dsky.l_10_6 -text "GIMBAL \nLOCK" -font ${font1} -bg $colb2 -padx 4
 pack .dsky.l_10_6 -side left -in .dsky.fdl2 -anchor w -fill x -fill y -pady 2 -padx 2
 # ----
 label .dsky.l_13_11 -text " STBY  " -font ${font1} -bg $colb2 -padx 4 -pady 8
 pack .dsky.l_13_11 -side left -in .dsky.fdl3 -anchor w -fill x -fill y -pady 2 -padx 2

 label .dsky.l_10_9 -text " PROG  " -font ${font1} -bg $colb2 -padx 4 -pady 8
 pack .dsky.l_10_9 -side left -in .dsky.fdl3 -anchor w -fill x -fill y -pady 2 -padx 2
 # ----
 label .dsky.l_11_5 -text "KEY REL" -font ${font1} -bg $colb2 -padx 4 -pady 8
 pack .dsky.l_11_5 -side left -in .dsky.fdl4 -anchor w -fill x -fill y -pady 2 -padx 2

 label .dsky.l_unkn1 -text "RESTART" -font ${font1} -bg $colb2 -padx 4 -pady 8
 pack .dsky.l_unkn1 -side left -in .dsky.fdl4 -anchor w -fill x -fill y -pady 2 -padx 2
 # ----
 label .dsky.l_11_7 -text "OPR ERR" -font ${font1} -bg $colb2 -padx 4 -pady 8
 pack .dsky.l_11_7 -side left -in .dsky.fdl5 -anchor w -fill x -fill y -pady 2 -padx 2

 label .dsky.l_10_8 -text "TRACKER" -font ${font1} -bg $colb2 -padx 4 -pady 8
 pack .dsky.l_10_8 -side left -in .dsky.fdl5 -anchor w -fill x -fill y -pady 2 -padx 2
 # ----
 label .dsky.l_empty1 -text "       " -font ${font1} -bg $colb2 -padx 4 -pady 8
 pack .dsky.l_empty1 -side left -in .dsky.fdl6 -anchor w -fill x -fill y -pady 2 -padx 2

 label .dsky.l_10_5 -text "  ALT  " -font ${font1} -bg $colb2 -padx 4 -pady 8
 pack .dsky.l_10_5 -side left -in .dsky.fdl6 -anchor w -fill x -fill y -pady 2 -padx 2
 # ----
 label .dsky.l_empty2 -text "       " -font ${font1} -bg $colb2 -padx 4 -pady 8
 pack .dsky.l_empty2 -side left -in .dsky.fdl7 -anchor w -fill x -fill y -pady 2 -padx 2

 label .dsky.l_10_3 -text "  VEL  " -font ${font1} -bg $colb2 -padx 4 -pady 8
 pack .dsky.l_10_3 -side left -in .dsky.fdl7 -anchor w -fill x -fill y -pady 2 -padx 2

 # ------------------------------------------------
 # --------------- DSKY Display -------------------
 # ------------------------------------------------
 label .dsky.l_11_2 -text "COMP\nACTY" -font ${font1} -bg $colb3 -fg black -padx 10 -pady 14
 pack .dsky.l_11_2 -side top -in .dsky.fd1a -anchor w -fill x -fill y

 label .dsky.l_prog -text " PROG " -font ${font1} -bg green -fg black -padx 3
 pack .dsky.l_prog -side top -in .dsky.fd1b -anchor w -fill x -fill y

 # ----
 create_numbers M1 fd2b
 create_numbers M2 fd2b
 create_segments M1
 create_segments M2

 # ----
 label .dsky.l_verb -text " VERB " -font ${font1} -bg green -fg black -padx 3
 pack .dsky.l_verb -side top -in .dsky.fd3a -anchor w -fill x -fill y

 label .dsky.l_noun -text " NOUN " -font ${font1} -bg green -fg black -padx 3
 pack .dsky.l_noun -side top -in .dsky.fd3b -anchor w -fill x -fill y

 # ---
 create_numbers V1 fd4a
 create_numbers V2 fd4a
 create_segments V1
 create_segments V2

 create_numbers N1 fd4b
 create_numbers N2 fd4b
 create_segments N1
 create_segments N2

 # ---- First Register ----
 canvas .dsky.tl1 -width 140 -height 2 -relief flat -bg green -borderwidth 0 -selectborderwidth 0 -insertborderwidth 0 -highlightbackground $colb3 -highlightcolor $colb3
 pack .dsky.tl1 -side left -in .dsky.fd51

 label .dsky.l_S1 -text " " -font ${font4} -bg $colb3 -fg $colb3
 pack .dsky.l_S1 -side left -in .dsky.fd5 -anchor w -fill x -fill y -padx 1

 create_numbers D11 fd5
 create_numbers D12 fd5
 create_numbers D13 fd5
 create_numbers D14 fd5
 create_numbers D15 fd5
 create_segments D11
 create_segments D12
 create_segments D13
 create_segments D14
 create_segments D15

 # ---- Second Register ----
 canvas .dsky.tl2 -width 140 -height 2 -relief flat -bg green -borderwidth 0 -selectborderwidth 0 -insertborderwidth 0 -highlightbackground $colb3 -highlightcolor $colb3
 pack .dsky.tl2 -side left -in .dsky.fd61

 label .dsky.l_S2 -text " " -font ${font4} -bg $colb3 -fg $colb3
 pack .dsky.l_S2 -side left -in .dsky.fd6 -anchor w -fill x -fill y -padx 1

 create_numbers D21 fd6
 create_numbers D22 fd6
 create_numbers D23 fd6
 create_numbers D24 fd6
 create_numbers D25 fd6
 create_segments D21
 create_segments D22
 create_segments D23
 create_segments D24
 create_segments D25

 # ---- Third Register ----
 canvas .dsky.tl3 -width 140 -height 2 -relief flat -bg green -borderwidth 0 -selectborderwidth 0 -insertborderwidth 0 -highlightbackground $colb3 -highlightcolor $colb3
 pack .dsky.tl3 -side left -in .dsky.fd71

 label .dsky.l_S3 -text " " -font ${font4} -bg $colb3 -fg $colb3
 pack .dsky.l_S3 -side left -in .dsky.fd7 -anchor w -fill x -fill y -padx 1

 create_numbers D31 fd7
 create_numbers D32 fd7
 create_numbers D33 fd7
 create_numbers D34 fd7
 create_numbers D35 fd7
 create_segments D31
 create_segments D32
 create_segments D33
 create_segments D34
 create_segments D35
}


# ********************************************************************************************
# **** Function:  Set DSKY Signals                                                        ****
# ********************************************************************************************
proc dsky_signals {} {
 global bo colb2 colb3 calcol flash_flag cdata m2 m3 s1p s2p s3p s1m s2m s3m R1 R2 R3 R4
 global DSKY_MEM Delta_Time

 if {[winfo exists .dsky] != 1} {return}

 set AAAA  [string range $cdata(10) 0 3]
 set B     [string index $cdata(10) 4]
 set CCCCC [string range $cdata(10) 5 9]
 set DDDDD [string range $cdata(10) 10 14]

 if {[winfo exists .dsky] == 1} {
   # ---- AGC Bit Lamp Signals ----
   if {$bo(11,2)} {catch {.dsky.l_11_2 configure -bg green}} else {catch {.dsky.l_11_2 configure -bg $colb3}}
   if {$bo(11,3)} {catch {.dsky.l_11_3 configure -bg white}} else {catch {.dsky.l_11_3 configure -bg $colb2}}
   if {$bo(11,4)} {catch {.dsky.l_11_4 configure -bg orange}} else {catch {.dsky.l_11_4 configure -bg $colb2}}
   if {$bo(13,11)} {catch {.dsky.l_13_11 configure -bg white}} else {catch {.dsky.l_13_11 configure -bg $colb2}}
   if {$bo(11,5) == 1 && $flash_flag == 1} {catch {.dsky.l_11_5 configure -bg white}} else {catch {.dsky.l_11_5 configure -bg $colb2}}
   if {$bo(11,7) == 1 && $flash_flag == 1} {catch {.dsky.l_11_7 configure -bg white}} else {catch {.dsky.l_11_7 configure -bg $colb2}}

   # ---- Channel 10 Lamp Signals ----
   if {$AAAA == "1100"} {
      if {[string index $cdata(10) 12] == 1} {catch {.dsky.l_10_3 configure -bg orange}} else {catch {.dsky.l_10_3 configure -bg $colb2}}
      if {[string index $cdata(10) 11] == 1} {catch {.dsky.l_10_4 configure -bg white}} else {catch {.dsky.l_10_4 configure -bg $colb2}}
      if {[string index $cdata(10) 10] == 1} {catch {.dsky.l_10_5 configure -bg orange}} else {catch {.dsky.l_10_5 configure -bg $colb2}}
      if {[string index $cdata(10) 9] == 1} {catch {.dsky.l_10_6 configure -bg orange}} else {catch {.dsky.l_10_6 configure -bg $colb2}}
      if {[string index $cdata(10) 7] == 1} {catch {.dsky.l_10_8 configure -bg orange}} else {catch {.dsky.l_10_8 configure -bg $colb2}}
      if {[string index $cdata(10) 6] == 1} {catch {.dsky.l_10_9 configure -bg orange}} else {catch {.dsky.l_10_9 configure -bg $colb2}}
   }
   # ---- Display PROG ----
   if {$AAAA == "1011"} {
     catch {draw_number [conv_relay_dec "$CCCCC"] M1}
     catch {draw_number [conv_relay_dec "$DDDDD"] M2}
   }

   # ---- Display VERB ----
   if {$AAAA == "1010"} {
     catch {draw_number [conv_relay_dec "$CCCCC"] V1}
     catch {draw_number [conv_relay_dec "$DDDDD"] V2}
   }

   # ---- Display NOUN ----
   if {$AAAA == "1001"} {
     catch {draw_number [conv_relay_dec "$CCCCC"] N1}
     catch {draw_number [conv_relay_dec "$DDDDD"] N2}
   }

   # ---- Flash VERB and NOUN ----
   if {$bo(11,6) == 1} {
     set m2 1
     if {$flash_flag == 1} {
       if {$m3 == 1} {
         catch {.dsky.c_V1 delete $R1}; catch {.dsky.c_V2 delete $R2}
         catch {.dsky.c_N1 delete $R3}; catch {.dsky.c_N2 delete $R4}
         set m3 0
       }

     } else {
       if {$m3 == 0} {
         catch {set R1 [.dsky.c_V1 create rectangle 0 0 21 40 -fill $colb3 -outline $colb3]}
         catch {set R2 [.dsky.c_V2 create rectangle 0 0 21 40 -fill $colb3 -outline $colb3]}
         catch {set R3 [.dsky.c_N1 create rectangle 0 0 21 40 -fill $colb3 -outline $colb3]}
         catch {set R4 [.dsky.c_N2 create rectangle 0 0 21 40 -fill $colb3 -outline $colb3]}
         set m3 1
       }

     }
   }

   if {$bo(11,6) == 0 && $m2 == 1} {
     if {$m3 == 1} {
       catch {.dsky.c_V1 delete $R1}; catch {.dsky.c_V2 delete $R2}
       catch {.dsky.c_N1 delete $R3}; catch {.dsky.c_N2 delete $R4}
     }
     set m3 0
   }

   # ---- Digit D11 ----
   if {$AAAA == "1000"} {catch { catch {draw_number [conv_relay_dec "$DDDDD"] D11}}}

   # ---- Sign 1+; D12; D13 ----
   if {$AAAA == "0111"} {
     if {$B == 1} {set s1p 1} else {set s1p 0} 
     catch {draw_number [conv_relay_dec "$CCCCC"] D12}
     catch {draw_number [conv_relay_dec "$DDDDD"] D13}
   }

   # ---- Sign 1-; D14; D15 ----
   if {$AAAA == "0110"} {
     if {$B == 1} {set s1m 1} else {set s1m 0}  
     catch {draw_number [conv_relay_dec "$CCCCC"] D14}
     catch {draw_number [conv_relay_dec "$DDDDD"] D15}
   }

   # ---- Sign 2+; D21; D22 ----
   if {$AAAA == "0101"} {
     if {$B == 1} {set s2p 1} else {set s2p 0} 
     catch {draw_number [conv_relay_dec "$CCCCC"] D21}
     catch {draw_number [conv_relay_dec "$DDDDD"] D22}
   }

   # ---- Sign 2-; D23; D24 ----
   if {$AAAA == "0100"} {
     if {$B == 1} {set s2m 1} else {set s2m 0} 
     catch {draw_number [conv_relay_dec "$CCCCC"] D23}
     catch {draw_number [conv_relay_dec "$DDDDD"] D24}
   }

   # ---- D25; D31 ----
   if {$AAAA == "0011"} {
     catch {draw_number [conv_relay_dec "$CCCCC"] D25}
     catch {draw_number [conv_relay_dec "$DDDDD"] D31}
   }

   # ---- Sign 3+; D32; D33 ----
   if {$AAAA == "0010"} {
     if {$B == 1} {set s3p 1} else {set s3p 0} 
     catch {draw_number [conv_relay_dec "$CCCCC"] D32}
     catch {draw_number [conv_relay_dec "$DDDDD"] D33}
   }

   # ---- Sign 3-; D34; D35 ----
   if {$AAAA == "0001"} {
     if {$B == 1} {set s3m 1} else {set s3m 0} 
     catch {draw_number [conv_relay_dec "$CCCCC"] D34}
     catch {draw_number [conv_relay_dec "$DDDDD"] D35}
   }

   # ---- Set Sign 1 ----
   if {$s1p == 1} {.dsky.l_S1 configure -text "+" -fg green}
   if {$s1m == 1} {.dsky.l_S1 configure -text "-" -fg green}
   if {$s1p == 0 && $s1m == 0} {.dsky.l_S1 configure -text " " -fg $colb3}

   # ---- Set Sign 2 ----
   if {$s2p == 1} {.dsky.l_S2 configure -text "+" -fg green}
   if {$s2m == 1} {.dsky.l_S2 configure -text "-" -fg green}
   if {$s2p == 0 && $s2m == 0} {.dsky.l_S2 configure -text " " -fg $colb3}

   # ---- Set Sign 2 ----
   if {$s3p == 1} {.dsky.l_S3 configure -text "+" -fg green}
   if {$s3m == 1} {.dsky.l_S3 configure -text "-" -fg green}
   if {$s3p == 0 && $s3m == 0} {.dsky.l_S3 configure -text " " -fg $colb3}
 }
}


# *********************************************************************************************
# **** Function: Convert Relay Signals to Display Values                                   ****
# *********************************************************************************************
proc conv_relay_dec {par1} {
   global calcol colb3

   if {$par1 == "00000"} {set calcol $colb3; return " "}
   if {$par1 == "10101"} {set calcol green; return "0"}
   if {$par1 == "00011"} {set calcol green; return "1"}
   if {$par1 == "11001"} {set calcol green; return "2"}
   if {$par1 == "11011"} {set calcol green; return "3"}
   if {$par1 == "01111"} {set calcol green; return "4"}
   if {$par1 == "11110"} {set calcol green; return "5"}
   if {$par1 == "11100"} {set calcol green; return "6"}
   if {$par1 == "10011"} {set calcol green; return "7"}
   if {$par1 == "11101"} {set calcol green; return "8"}
   if {$par1 == "11111"} {set calcol green; return "9"}
}


# *********************************************************************************************
# **** Function: Create Numbers to Display   par1 = widget  par2 = in-frame                ****
# *********************************************************************************************
proc create_numbers {par1 par2} {
 global colb3 

 canvas .dsky.c_$par1 -width 19 -height 37 -relief flat -bg $colb3 -borderwidth 0 -selectborderwidth 0 -insertborderwidth 0 -highlightbackground $colb3 -highlightcolor $colb3

 pack .dsky.c_$par1 -side left -in .dsky.$par2 -padx 2
}


# *********************************************************************************************
# **** Function: Create Seven Segment Numbers                                              ****
# *********************************************************************************************
proc create_segments {par2} {
 global widgtM

 set widgtM(S1_$par2) [.dsky.c_$par2 create line 5 3 17 3 -width 3 -fill green]
 set widgtM(S2_$par2) [.dsky.c_$par2 create line 5 18 17 18 -width 3 -fill green]
 set widgtM(S3_$par2) [.dsky.c_$par2 create line 5 34 17 34 -width 3 -fill green]
 set widgtM(S4_$par2) [.dsky.c_$par2 create line 3 5 3 17 -width 3 -fill green]
 set widgtM(S5_$par2) [.dsky.c_$par2 create line 18 5 18 17 -width 3 -fill green]
 set widgtM(S6_$par2) [.dsky.c_$par2 create line 3 20 3 33 -width 3 -fill green]
 set widgtM(S7_$par2) [.dsky.c_$par2 create line 18 20 18 33 -width 3 -fill green]
}


# *********************************************************************************************
# **** Function: Draw Numer  par1 = Number  par2 = Widget                                  ****
# *********************************************************************************************
proc draw_number {par1 par2} {
 global colb4 widgtM

 if {$par1 == " "} {set S1 0; set S2 0; set S3 0; set S4 0; set S5 0; set S6 0; set S7 0}
 if {$par1 == "0"} {set S1 1; set S2 0; set S3 1; set S4 1; set S5 1; set S6 1; set S7 1}
 if {$par1 == "1"} {set S1 0; set S2 0; set S3 0; set S4 0; set S5 1; set S6 0; set S7 1}
 if {$par1 == "2"} {set S1 1; set S2 1; set S3 1; set S4 0; set S5 1; set S6 1; set S7 0}
 if {$par1 == "3"} {set S1 1; set S2 1; set S3 1; set S4 0; set S5 1; set S6 0; set S7 1}
 if {$par1 == "4"} {set S1 0; set S2 1; set S3 0; set S4 1; set S5 1; set S6 0; set S7 1}
 if {$par1 == "5"} {set S1 1; set S2 1; set S3 1; set S4 1; set S5 0; set S6 0; set S7 1}
 if {$par1 == "6"} {set S1 1; set S2 1; set S3 1; set S4 1; set S5 0; set S6 1; set S7 1}
 if {$par1 == "7"} {set S1 1; set S2 0; set S3 0; set S4 0; set S5 1; set S6 0; set S7 1}
 if {$par1 == "8"} {set S1 1; set S2 1; set S3 1; set S4 1; set S5 1; set S6 1; set S7 1}
 if {$par1 == "9"} {set S1 1; set S2 1; set S3 1; set S4 1; set S5 1; set S6 0; set S7 1}

 if {$S1 == 1} {.dsky.c_$par2 itemconfigure $widgtM(S1_$par2) -fill green} else {.dsky.c_$par2 itemconfigure $widgtM(S1_$par2) -fill $colb4}
 if {$S2 == 1} {.dsky.c_$par2 itemconfigure $widgtM(S2_$par2) -fill green} else {.dsky.c_$par2 itemconfigure $widgtM(S2_$par2) -fill $colb4}
 if {$S3 == 1} {.dsky.c_$par2 itemconfigure $widgtM(S3_$par2) -fill green} else {.dsky.c_$par2 itemconfigure $widgtM(S3_$par2) -fill $colb4}
 if {$S4 == 1} {.dsky.c_$par2 itemconfigure $widgtM(S4_$par2) -fill green} else {.dsky.c_$par2 itemconfigure $widgtM(S4_$par2) -fill $colb4}
 if {$S5 == 1} {.dsky.c_$par2 itemconfigure $widgtM(S5_$par2) -fill green} else {.dsky.c_$par2 itemconfigure $widgtM(S5_$par2) -fill $colb4}
 if {$S6 == 1} {.dsky.c_$par2 itemconfigure $widgtM(S6_$par2) -fill green} else {.dsky.c_$par2 itemconfigure $widgtM(S6_$par2) -fill $colb4}
 if {$S7 == 1} {.dsky.c_$par2 itemconfigure $widgtM(S7_$par2) -fill green} else {.dsky.c_$par2 itemconfigure $widgtM(S7_$par2) -fill $colb4}
}
