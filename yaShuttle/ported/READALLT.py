#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   READALLT.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-10-24 RSB  Ported from XPL.
"""

import g

#*************************************************************************
# PROCEDURE NAME:  READ_ALL_TYPE
# MEMBER NAME:     READALLT
# FUNCTION RETURN TYPE:
#          BIT(8)
# INPUT PARAMETERS:
#          P                 BIT(16)
# LOCAL DECLARATIONS:
#          I                 BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          CHAR_TYPE
#          EVIL_FLAG
#          FIXL
#          FIXV
#          FOREVER
#          MAJ_STRUC
#          PSEUDO_TYPE
#          PTR
#          SYM_FLAGS
#          SYM_LENGTH
#          SYM_LINK1
#          SYM_LINK2
#          SYM_TAB
#          SYM_TYPE
#          SYT_FLAGS
#          SYT_LINK1
#          SYT_LINK2
#          SYT_TYPE
#          VAR_LENGTH
# CALLED BY:
#          SYNTHESIZE
#*************************************************************************

def READ_ALL_TYPE(P):
    # Local I.
    #DECLARE (P,I) BIT(16);
    if g.PSEUDO_TYPE[g.PTR[P]]==g.MAJ_STRUC: #DO
        I=g.FIXL[P];
        if (g.SYT_FLAGS(g.VAR_LENGTH(g.FIXV[P]))&g.EVIL_FLAG)!=0: return 0;
        while True:
            while g.SYT_LINK1(I)!=0:
                I=g.SYT_LINK1(I);
            #END
            if g.SYT_TYPE(I)!=g.CHAR_TYPE: return 1;
            while g.SYT_LINK2(I)<0:
                I=-g.SYT_LINK2(I);
                if I==g.FIXL[P]: return 0;
            #END
            I = g.SYT_LINK2(I);
        #END
    #END
    else: return g.PSEUDO_TYPE[g.PTR[P]]!=g.CHAR_TYPE;
#END
