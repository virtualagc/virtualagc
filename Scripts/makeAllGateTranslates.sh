#!/bin/bash

cd ~/git/virtualagc-schematics/Schematics

makeGateTranslate.sh A01 scaler 2005259A $1
makeGateTranslate.sh A02 timer 2005260A $1
makeGateTranslate.sh A03 sq_register 2005251A $1
makeGateTranslate.sh A04 stage_branch 2005262A $1
makeGateTranslate.sh A05 crosspoint_nqi 2005261A $1
makeGateTranslate.sh A06 crosspoint_ii 2005263A $1
makeGateTranslate.sh A07 service_gates 2005252A $1
makeGateTranslate.sh A08 four_bit_1 2005255- $1
makeGateTranslate.sh A09 four_bit_2 2005256A $1
makeGateTranslate.sh A10 four_bit_3 2005257A $1
makeGateTranslate.sh A11 four_bit_4 2005258A $1
makeGateTranslate.sh A12 parity_s_register 2005253A $1
makeGateTranslate.sh A13 alarms 2005269- $1
makeGateTranslate.sh A14 memory_timing_addressing 2005264A $1
makeGateTranslate.sh A15 rupt_service 2005265A $1
makeGateTranslate.sh A16 inout_i 2005266- $1
makeGateTranslate.sh A17 inout_ii 2005267A $1
makeGateTranslate.sh A18 inout_iii 2005268A $1
makeGateTranslate.sh A19 inout_iv 2005270- $1
makeGateTranslate.sh A20 counter_cell_i 2005254- $1
makeGateTranslate.sh A21 counter_cell_ii 2005250- $1
makeGateTranslate.sh A22 inout_v 2005271- $1
makeGateTranslate.sh A23 inout_vi 2005272A $1
makeGateTranslate.sh A24 inout_vii 2005273A $1
makeGateTranslate.sh B01 fixed_erasable_memory fixed_erasable_memory $1
