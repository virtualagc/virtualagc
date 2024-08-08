#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   CHECKTOK.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g

'''
 #*************************************************************************
 # PROCEDURE NAME:  CHECK_TOKEN
 # MEMBER NAME:     CHECKTOK
 # FUNCTION RETURN TYPE:
 #          FIXED
 # INPUT PARAMETERS:
 #          NSTATE            BIT(16)
 #          NLOOK             BIT(16)
 #          NTOKEN            BIT(16)
 # EXTERNAL VARIABLES REFERENCED:
 #          APPLY1
 #          APPLY2
 #          INDEX1
 #          INDEX2
 #          LOOK1
 #          LOOK2
 #          MAXL#
 #          MAXP#
 #          MAXR#
 #          READ1
 #          SP
 #          STATE_STACK
 # EXTERNAL VARIABLES CHANGED:
 #          I
 #          J
 #          K
 # CALLED BY:
 #          RECOVER
 #*************************************************************************
'''

 #              SYNTACTIC PARSING FUNCTIONS

def CHECK_TOKEN(NSTATE,NLOOK,NTOKEN):
    # No local variables.

    #  THIS PROCEDURE LOOKS AHEAD AT FUTURE STATE TRANSITIONS FROM THE GIVEN
    #  STATE..  IF THE (READ) STATE CAN TAKE THE GIVEN TOKEN, OR IF ANOTHER
    #  SUCH READ STATE CAN BE REACHED BY TAKING ANOTHER BRANCH FROM A  LOOK-
    #  AHEAD STATE TO WHICH TRANSITION TO THE FIRST READ STATE WAS MADE, THEN
    #  THE STATE ACCEPTING THE TOKEN IS RETURNED. OTHERWISE ZERO IS RETURNED.
    
    g.K=g.SP-1;
    while NSTATE>0:
        if NSTATE<=g.MAXRp:   # READ STATE
            g.I=g.INDEX1[NSTATE];
            for g.I in range(g.I, g.I+g.INDEX2[NSTATE]-1):
                if g.READ1[g.I]==NTOKEN:
                    if NLOOK>=0: 
                        return NSTATE;
                    else:
                        return -NLOOK;
            if NLOOK<=0: 
                return 0;
            NSTATE=NLOOK;
            NLOOK=-NSTATE;
        elif NSTATE>g.MAXPp:    #  APPLY STATE
            g.I=g.INDEX1[NSTATE];
            g.K=g.K-g.INDEX2[NSTATE];
            g.J=g.STATE_STACK[g.K];
            while g.J!=g.APPLY1[g.I]:
                if g.APPLY1[g.I]==0: 
                    g.J=0;
                else:
                    g.I=g.I+1;
            NSTATE=g.APPLY2[g.I];
        elif NSTATE<=g.MAXLp:    # LOOK AHEAD STATE
            g.I=g.INDEX1[NSTATE];
            g.J=NTOKEN;
            while g.LOOK1[g.I]!=g.J:
                if g.LOOK1[g.I]==0: 
                    g.J=0;
                else:
                    g.I=g.I+1;
            NSTATE=g.LOOK2[g.I];
        else:
            NSTATE=0;     #  PUSH STATE
    return 0;
