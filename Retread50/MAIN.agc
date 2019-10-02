### FILE="Main.annotation"
# Copyright:   	Public domain.
# Filename:    	MAIN.agc
# Purpose:     Part of the source code for AGC program Retread 50. 
# Assembler:   yaYUL
# Contact:     Ron Burkey <info@sandroid.org>.
# Website:     www.ibiblio.org/apollo/Restoration.html
# Mod history: 2019-06-12 MAS  Created.
#              2019-10-01 MAS  Updated for completed disassembly.
#               
# MAIN.agc is a little different from the other Retread50 files  
# provided, in that it doesn't represent anything that appears 
# directly in the original source.  What we have done for 
# organizational purposes is to split the huge monolithic source 
# code into smaller, more manageable chunks--i.e., into individual
# source files.  Those files are rejoined within this file as 
# "includes".  It just makes it a little easier to work with.  The
# code chunks correspond to natural divisions into sub-programs.  
# The divisions are by the assembly listing itself.

# Source file name                       Starting Page
# ----------------                       -------------

$VERB_AND_NOUN_INFORMATION.agc         # 1
$ERASABLE_ASSIGNMENTS.agc              # 5
$INPUT_OUTPUT_CHANNELS.agc             # 14
$INTERRUPT_LEAD_INS.agc                # 15
$LIST-PROCESSING_INTERPRETER.agc       # 17
$INTER-BANK_COMMUNICATION.agc          # 105
$EXECUTIVE.agc                         # 107
$WAITLIST.agc                          # 118
$FRESH_START_AND_RESTART.agc           # 124
$T4RUPT_PROGRAM.agc                    # 128
$KEYRUPT,_UPRUPT.agc                   # 131
$PINBALL_GAME__BUTTONS_AND_LIGHTS.agc  # 135
$AGC_BLK2_INSTRUCTION_CHECK.agc        # 210
$EXTENDED_VERBS_FOR_MODING.agc         # 243

#Assembly-tables                       # 244+
