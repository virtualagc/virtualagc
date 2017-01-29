### FILE="Main.annotation"
# Copyright:   Public domain.
# Filename:    MAIN.agc
# Purpose:     Part of the source code for SUPER JOB, a program developed
#              at Raytheon to exercise the Auxiliary Memory for the AGC.
#              It appears to have been developed from scratch, and shares
#              no heritage with any programs from MIT. It was also built
#              with a Raytheon assembler rather than YUL or GAP.
# Assembler:   yaYUL
# Contact:     Ron Burkey <info@sandroid.org>.
# Website:     https://www.ibiblio.org/apollo/index.html
# Page Scans:  http://www.ibiblio.org/apollo/Documents/R68-4125-Volume2.pdf
# Mod history: 2017-01-27 MAS  Created.
# 
# MAIN.agc is a little different from the other SuperJob files
# provided, in that it doesn't represent anything that appears 
# directly in the original source.  What we have done for 
# organizational purposes is to split the huge monolithic source 
# code into smaller, more manageable chunks--i.e., into individual
# source files.  Those files are rejoined within this file as 
# "includes".  It just makes it a little easier to work with.
# SuperJob doesn't divide quite as nicely as MIT-developed
# programs, so I've simply split out "SPECIAL AND CENTRAL" and
# "CHANNELS" from "SUPER JOB". The split between "SUPER JOB"
# and "AM DEMONSTRATION" appears natural; in fact, the look
# like they were assembled separately.
#
# The following note appears on the page preceding the listings
# in the appendix:
# """
# ACM DEMONSTRATION CHANGES
#
# NOTE:  In order to execute function i of the Utility
#        Verb (the word-for-word check using Verb 00)
#        the following changes must be made to the
#        program:
#
#             BANK         ADDRESS      CHANGE TO
#              16            2446         12453
#              16            2453         30007
#              16            2454         54173
#              16            2455         07446
# """
# These notes are replicated next to the relevant addresses
# in SUPER_JOB.agc.

# Source file name        Starting Page
# ----------------        -------------

$SPECIAL_AND_CENTRAL.agc  # D-2
$CHANNELS.agc             # D-4
$SUPER_JOB.agc            # D-4
$AM_DEMONSTRATION.agc     # D-46

